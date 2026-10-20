import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/user/domain/_domain.dart';

class MockGuestUserRepository extends Mock implements GuestUserRepository {}

extension MockGuestUserRepositoryStub on MockGuestUserRepository {
  void stubGetGuestUser(GuestUserEntity? user) {
    when(getGuestUser).thenAnswer((_) async => user);
  }

  void stubSaveGuestUser(GuestUserEntity user) {
    when(() => saveGuestUser(user)).thenAnswer((_) async {});
  }

  void stubSaveGuestUserThrows(GuestUserEntity user, Object error) {
    when(() => saveGuestUser(user)).thenThrow(error);
  }
}
