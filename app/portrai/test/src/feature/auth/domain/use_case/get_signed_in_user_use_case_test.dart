import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';

import '../../../../../mock/feature/auth/domain/repository/mock_auth_repository.dart';

void main() {
  group('GetSignedInUserUseCase', () {
    late MockAuthRepository authRepository;

    setUp(() => authRepository = MockAuthRepository());

    test('should return the user when a user is signed in', () async {
      const user = AuthUserEntity(id: 'owner-uid', email: 'owner@example.com');
      authRepository.stubGetSignedInUser(user);

      final signedInUserEither = await GetSignedInUserUseCase(authRepository)();

      expect(signedInUserEither.right, user);
    });

    test('should return null when nobody is signed in', () async {
      authRepository.stubGetSignedInUser(null);

      final signedInUserEither = await GetSignedInUserUseCase(authRepository)();

      expect(signedInUserEither.isRight, isTrue);
      expect(signedInUserEither.right, isNull);
    });

    test('should return an unknown failure with its cause when the repository '
        'throws', () async {
      const exception = AuthUnknownException();
      authRepository.stubGetSignedInUserThrows(exception);

      final signedInUserEither = await GetSignedInUserUseCase(authRepository)();

      expect(signedInUserEither.left, isA<GetSignedInUserUnknownFailure>());
      expect(signedInUserEither.left.cause, same(exception));
    });
  });
}
