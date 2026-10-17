import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';

import '../../../../../mock/feature/onboarding/domain/repository/mock_user_repository.dart';

void main() {
  group('SaveUserUseCase', () {
    const user = UserEntity(role: UserRole.recruiter);

    test('should save the user when the repository succeeds', () async {
      final repository = MockUserRepository()..stubSaveUser(user);

      final saveUserEither = await SaveUserUseCase(repository)(user);

      expect(saveUserEither.isRight, isTrue);
      verify(() => repository.saveUser(user)).called(1);
    });

    test(
      'should preserve the cause in an unknown failure when saving throws',
      () async {
        final error = StateError('Cannot write user');
        final repository = MockUserRepository()
          ..stubSaveUserThrows(user, error);

        final saveUserEither = await SaveUserUseCase(repository)(user);

        expect(saveUserEither.left, isA<SaveUserUnknownFailure>());
        expect(saveUserEither.left.cause, same(error));
      },
    );
  });
}
