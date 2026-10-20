import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/user/domain/_domain.dart';

import '../../../../../mock/feature/user/domain/repository/mock_guest_user_repository.dart';

void main() {
  group('GetGuestUserUseCase', () {
    test('should return the saved user when the repository has one', () async {
      const user = GuestUserEntity(role: UserRole.developer);
      final repository = MockGuestUserRepository()..stubGetGuestUser(user);

      final userEither = await GetGuestUserUseCase(repository)();

      expect(userEither.right, user);
    });

    test('should return null when no user was saved', () async {
      final repository = MockGuestUserRepository()..stubGetGuestUser(null);

      final userEither = await GetGuestUserUseCase(repository)();

      expect(userEither.isRight, isTrue);
      expect(userEither.right, isNull);
    });
  });
}
