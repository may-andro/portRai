import 'package:portrai/src/feature/user/user.dart';

abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});

  /// The signed-in user, or null when nobody is signed in. Waits for a
  /// restored session on app start instead of reporting it as signed out.
  Future<AuthUserEntity?> getSignedInUser();
}
