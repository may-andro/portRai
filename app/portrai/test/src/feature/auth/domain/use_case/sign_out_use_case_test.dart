import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';

import '../../../../../mock/feature/auth/domain/repository/mock_auth_repository.dart';

void main() {
  group('SignOutUseCase', () {
    late MockAuthRepository authRepository;

    setUp(() => authRepository = MockAuthRepository());

    test('should sign out through the repository when called', () async {
      authRepository.stubSignOut();

      final signOutEither = await SignOutUseCase(authRepository)();

      expect(signOutEither.isRight, isTrue);
      verify(authRepository.signOut).called(1);
    });

    test('should return a network failure when the repository has no '
        'connection', () async {
      const exception = AuthNetworkException();
      authRepository.stubSignOutThrows(exception);

      final signOutEither = await SignOutUseCase(authRepository)();

      expect(signOutEither.left, isA<SignOutNetworkFailure>());
      expect(signOutEither.left.cause, same(exception));
    });

    test('should return an unknown failure when the repository throws '
        'anything else', () async {
      authRepository.stubSignOutThrows(const AuthUnknownException());

      final signOutEither = await SignOutUseCase(authRepository)();

      expect(signOutEither.left, isA<SignOutUnknownFailure>());
    });
  });
}
