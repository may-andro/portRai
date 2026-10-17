import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';

import '../../../../../mock/feature/onboarding/domain/repository/mock_user_repository.dart';

void main() {
  group('GetUserUseCase', () {
    test('should return the saved user when the repository has one', () async {
      const user = UserEntity(role: UserRole.developer);
      final repository = MockUserRepository()..stubGetUser(user);

      final userEither = await GetUserUseCase(repository)();

      expect(userEither.right, user);
    });

    test('should return null when no user was saved', () async {
      final repository = MockUserRepository()..stubGetUser(null);

      final userEither = await GetUserUseCase(repository)();

      expect(userEither.isRight, isTrue);
      expect(userEither.right, isNull);
    });
  });
}
