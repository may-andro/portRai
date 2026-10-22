import 'package:firebase/firebase.dart';
import 'package:mocktail/mocktail.dart';

class MockFbAuthController extends Mock implements FbAuthController {}

extension MockFbAuthControllerStub on MockFbAuthController {
  /// Stubs `signIn(email:, password:)` to return [userId].
  void stubSignIn(String userId) {
    when(
      () => signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => userId);
  }

  /// Stubs `signIn(email:, password:)` to throw [error].
  void stubSignInThrows(Object error) {
    when(
      () => signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(error);
  }

  /// Stubs `authStateChanges` to emit [users] in order.
  void stubAuthStateChanges(List<User?> users) {
    when(() => authStateChanges).thenAnswer((_) => Stream.fromIterable(users));
  }

  /// Stubs `currentUser` to return [user].
  void stubCurrentUser(User? user) {
    when(() => currentUser).thenReturn(user);
  }

  /// Stubs `signOut()` to complete.
  void stubSignOut() {
    when(signOut).thenAnswer((_) async {});
  }

  /// Stubs `signOut()` to throw [error].
  void stubSignOutThrows(Object error) {
    when(signOut).thenThrow(error);
  }

  /// Stubs `authStateChanges` to emit [error].
  void stubAuthStateChangesThrows(Object error) {
    when(() => authStateChanges).thenAnswer((_) => Stream.error(error));
  }
}
