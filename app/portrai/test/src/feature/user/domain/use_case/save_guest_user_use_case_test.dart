import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/user/domain/_domain.dart';

import '../../../../../mock/feature/user/domain/repository/mock_guest_user_repository.dart';

void main() {
  group('SaveGuestUserUseCase', () {
    const user = GuestUserEntity(role: UserRole.recruiter);

    test('should save the user when the repository succeeds', () async {
      final repository = MockGuestUserRepository()..stubSaveGuestUser(user);

      final saveGuestUserEither = await SaveGuestUserUseCase(repository)(user);

      expect(saveGuestUserEither.isRight, isTrue);
      verify(() => repository.saveGuestUser(user)).called(1);
    });

    test(
      'should preserve the cause in an unknown failure when saving throws',
      () async {
        final error = StateError('Cannot write user');
        final repository = MockGuestUserRepository()
          ..stubSaveGuestUserThrows(user, error);

        final saveGuestUserEither = await SaveGuestUserUseCase(repository)(
          user,
        );

        expect(saveGuestUserEither.left, isA<SaveGuestUserUnknownFailure>());
        expect(saveGuestUserEither.left.cause, same(error));
      },
    );
  });
}
