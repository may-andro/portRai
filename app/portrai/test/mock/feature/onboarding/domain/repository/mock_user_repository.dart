import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';

class MockUserRepository extends Mock implements UserRepository {}

extension MockUserRepositoryStub on MockUserRepository {
  void stubGetUser(UserEntity? user) {
    when(getUser).thenAnswer((_) async => user);
  }

  void stubSaveUser(UserEntity user) {
    when(() => saveUser(user)).thenAnswer((_) async {});
  }

  void stubSaveUserThrows(UserEntity user, Object error) {
    when(() => saveUser(user)).thenThrow(error);
  }
}
