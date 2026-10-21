import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

extension MockAuthRepositoryStub on MockAuthRepository {
  void stubSignIn() {
    when(
      () => signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  }

  void stubSignInThrows(Object error) {
    when(
      () => signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(error);
  }

  void stubGetSignedInUser(AuthUserEntity? user) {
    when(getSignedInUser).thenAnswer((_) async => user);
  }

  void stubGetSignedInUserThrows(Object error) {
    when(getSignedInUser).thenThrow(error);
  }

  void stubSignOut() {
    when(signOut).thenAnswer((_) async {});
  }

  void stubSignOutThrows(Object error) {
    when(signOut).thenThrow(error);
  }
}
