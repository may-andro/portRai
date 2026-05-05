import 'package:firebase/src/auth/auth_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FbAuthController {
  FbAuthController(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  /// Gets the current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Checks if a user is currently signed in
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Creates a new user account with email and password
  Future<String> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user == null) {
        throw const UserCreationFailedException();
      }

      return user.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException.fromException(e);
    }
  }

  /// Deletes the current user account with reauthentication
  /// Use this when you need to ensure the user is recently authenticated
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw const NoCurrentUserException();
      }

      // Reauthenticate the user before deletion
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Now delete the account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException.fromException(e);
    }
  }

  /// Signs in a user with email and password
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user == null) {
        throw const SignInFailedException();
      }

      return user.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException.fromException(e);
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Updates the password for the currently signed-in user with reauthentication
  /// Use this when you need to ensure the user is recently authenticated
  Future<void> updatePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw const NoCurrentUserException();
      }

      // Reauthenticate the user before password update
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Now update the password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException.fromException(e);
    }
  }

  /// Sends a password reset email to the user
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Completes the password reset process using the code from the email
  /// and sets a new password for the user
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Verifies a password reset code is valid without resetting the password
  /// Returns the email address associated with the code
  Future<String> verifyPasswordResetCode({required String code}) async {
    try {
      return await _firebaseAuth.verifyPasswordResetCode(code);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      throw AuthException.fromException(e);
    }
  }

  /// Extracts the password reset code from a Firebase password reset URL
  /// This is typically used when handling deep links from password reset emails
  ///
  /// Example URL: https://yourapp.firebaseapp.com/__/auth/action?mode=resetPassword&oobCode=ABC123&apiKey=...
  /// Returns: "ABC123"
  static String? extractResetCodeFromUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Check if this is a Firebase auth action URL
      if (!uri.path.contains('/__/auth/action')) {
        return null;
      }

      // Check if it's a password reset action
      final mode = uri.queryParameters['mode'];
      if (mode != 'resetPassword') {
        return null;
      }

      // Extract the oobCode (out-of-band code)
      return uri.queryParameters['oobCode'];
    } catch (e) {
      return null;
    }
  }
}
