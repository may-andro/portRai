import 'package:firebase/firebase.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/data/_data.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';

import '../../../../../mock/feature/auth/data/repository/mock_fb_auth_controller.dart';
import '../../../../../mock/feature/auth/data/repository/mock_user.dart';

void main() {
  group('FirebaseAuthRepository', () {
    late MockFbAuthController authController;
    late FirebaseAuthRepository repository;

    setUp(() {
      authController = MockFbAuthController();
      repository = FirebaseAuthRepository(
        authController,
        const AuthUserMapper(),
      );
    });

    test('should sign in through the controller when signing in', () async {
      authController.stubSignIn('owner-uid');

      await repository.signIn(email: 'owner@example.com', password: 'secret');

      verify(
        () => authController.signIn(
          email: 'owner@example.com',
          password: 'secret',
        ),
      ).called(1);
    });

    for (final (layerException, exceptionMatcher) in [
      (
        const firebase.WrongPasswordException(),
        isA<AuthInvalidCredentialsException>(),
      ),
      (
        const firebase.UserNotFoundException(),
        isA<AuthInvalidCredentialsException>(),
      ),
      (
        const firebase.InvalidCredentialException(),
        isA<AuthInvalidCredentialsException>(),
      ),
      (
        const firebase.InvalidEmailException(),
        isA<AuthInvalidCredentialsException>(),
      ),
      (
        const firebase.UserDisabledException(),
        isA<AuthInvalidCredentialsException>(),
      ),
      (
        const firebase.TooManyRequestsException(),
        isA<AuthTooManyRequestsException>(),
      ),
      (
        const firebase.NetworkRequestFailedException(),
        isA<AuthNetworkException>(),
      ),
      (
        const firebase.OperationNotAllowedException(),
        isA<AuthUnknownException>(),
      ),
    ]) {
      test('should throw the matching auth exception when the controller '
          'throws ${layerException.runtimeType}', () async {
        authController.stubSignInThrows(layerException);

        await expectLater(
          repository.signIn(email: 'owner@example.com', password: 'secret'),
          throwsA(exceptionMatcher),
        );
      });
    }

    test('should keep the controller error as the cause when signing in '
        'fails', () async {
      const layerException = firebase.TooManyRequestsException();
      authController.stubSignInThrows(layerException);

      await expectLater(
        repository.signIn(email: 'owner@example.com', password: 'secret'),
        throwsA(
          isA<AuthTooManyRequestsException>().having(
            (exception) => exception.cause,
            'cause',
            same(layerException),
          ),
        ),
      );
    });

    test('should return the user from the first auth state when a session '
        'is restored', () async {
      final user = MockUser()
        ..stubAccount(userId: 'owner-uid', email: 'owner@example.com');
      authController.stubAuthStateChanges([user, null]);

      expect(
        await repository.getSignedInUser(),
        const AuthUserEntity(id: 'owner-uid', email: 'owner@example.com'),
      );
    });

    test('should return null when the first auth state has no user', () async {
      authController.stubAuthStateChanges([null]);

      expect(await repository.getSignedInUser(), isNull);
    });

    test('should throw an unknown auth exception when the auth state stream '
        'fails', () async {
      authController.stubAuthStateChangesThrows(StateError('broken'));

      await expectLater(
        repository.getSignedInUser(),
        throwsA(isA<AuthUnknownException>()),
      );
    });
  });
}
