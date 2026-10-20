import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';

import '../../../../../mock/feature/auth/domain/repository/mock_auth_repository.dart';

void main() {
  group('SignInUseCase', () {
    late MockAuthRepository authRepository;
    late SignInUseCase signInUseCase;

    setUp(() {
      authRepository = MockAuthRepository();
      signInUseCase = SignInUseCase(authRepository);
    });

    test('should sign in with the trimmed email when the credentials are '
        'filled in', () async {
      authRepository.stubSignIn();

      final signInEither = await signInUseCase(
        const SignInParam(email: '  owner@example.com ', password: 'secret'),
      );

      expect(signInEither.isRight, isTrue);
      verify(
        () => authRepository.signIn(
          email: 'owner@example.com',
          password: 'secret',
        ),
      ).called(1);
    });

    for (final (description, email, password) in [
      ('the email is empty', '', 'secret'),
      ('the email is only whitespace', '   ', 'secret'),
      ('the password is empty', 'owner@example.com', ''),
    ]) {
      test('should return a missing credentials failure without signing in '
          'when $description', () async {
        final signInEither = await signInUseCase(
          SignInParam(email: email, password: password),
        );

        expect(signInEither.left, isA<SignInMissingCredentialsFailure>());
        verifyNever(
          () => authRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      });
    }

    for (final (exception, failureMatcher) in [
      (
        const AuthInvalidCredentialsException(),
        isA<SignInInvalidCredentialsFailure>(),
      ),
      (
        const AuthTooManyRequestsException(),
        isA<SignInTooManyRequestsFailure>(),
      ),
      (const AuthNetworkException(), isA<SignInNetworkFailure>()),
      (const AuthUnknownException(), isA<SignInUnknownFailure>()),
      (StateError('unexpected'), isA<SignInUnknownFailure>()),
    ]) {
      test('should return the matching failure with its cause when the '
          'repository throws ${exception.runtimeType}', () async {
        authRepository.stubSignInThrows(exception);

        final signInEither = await signInUseCase(
          const SignInParam(email: 'owner@example.com', password: 'secret'),
        );

        expect(signInEither.left, failureMatcher);
        expect(signInEither.left.cause, same(exception));
      });
    }

    test('should hide the credentials when the param is printed', () {
      const signInParam = SignInParam(
        email: 'owner@example.com',
        password: 'secret',
      );

      expect(signInParam.toString(), isNot(contains('owner@example.com')));
      expect(signInParam.toString(), isNot(contains('secret')));
    });
  });
}
