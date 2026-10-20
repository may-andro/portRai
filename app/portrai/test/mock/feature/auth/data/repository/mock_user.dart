import 'package:firebase/firebase.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {}

extension MockUserStub on MockUser {
  /// Stubs `uid` to return [userId] and `email` to return [email].
  void stubAccount({required String userId, String? email}) {
    when(() => uid).thenReturn(userId);
    when(() => this.email).thenReturn(email);
  }
}
