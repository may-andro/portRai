import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Base sealed class for authentication exceptions
sealed class AuthException implements AppException {
  const AuthException(this.message);

  /// Factory constructor to create AuthException from FirebaseAuthException
  factory AuthException.fromFirebaseAuth(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => const UserNotFoundException(),
      'wrong-password' => const WrongPasswordException(),
      'invalid-email' => const InvalidEmailException(),
      'email-already-in-use' => const EmailAlreadyInUseException(),
      'weak-password' => const WeakPasswordException(),
      'too-many-requests' => const TooManyRequestsException(),
      'requires-recent-login' => const RequiresRecentLoginException(),
      'user-disabled' => const UserDisabledException(),
      'operation-not-allowed' => const OperationNotAllowedException(),
      'invalid-credential' => const InvalidCredentialException(),
      'credential-already-in-use' => const CredentialAlreadyInUseException(),
      'network-request-failed' => const NetworkRequestFailedException(),
      'invalid-action-code' => const InvalidPasswordResetCodeException(),
      'expired-action-code' => const ExpiredPasswordResetCodeException(),
      _ => UnknownAuthException('Firebase error: ${e.message}'),
    };
  }

  /// Factory constructor for general exceptions
  factory AuthException.fromException(Object e) {
    if (e is FirebaseAuthException) {
      return AuthException.fromFirebaseAuth(e);
    }
    return UnknownAuthException('An unexpected error occurred: $e');
  }

  final String message;

  @override
  String toString() => message;
}

/// User not found exception
final class UserNotFoundException extends AuthException {
  const UserNotFoundException()
    : super('No account found with this email address.');
}

/// Wrong password exception
final class WrongPasswordException extends AuthException {
  const WrongPasswordException()
    : super('Incorrect password. Please try again.');
}

/// Invalid email exception
final class InvalidEmailException extends AuthException {
  const InvalidEmailException() : super('Please enter a valid email address.');
}

/// Email already in use exception
final class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
    : super('An account with this email already exists.');
}

/// Weak password exception
final class WeakPasswordException extends AuthException {
  const WeakPasswordException()
    : super('Password is too weak. Please choose a stronger password.');
}

/// Too many requests exception
final class TooManyRequestsException extends AuthException {
  const TooManyRequestsException()
    : super('Too many failed attempts. Please try again later.');
}

/// Requires recent login exception
final class RequiresRecentLoginException extends AuthException {
  const RequiresRecentLoginException()
    : super(
        'This action requires recent authentication. Please sign in again.',
      );
}

/// User disabled exception
final class UserDisabledException extends AuthException {
  const UserDisabledException() : super('This account has been disabled.');
}

/// Operation not allowed exception
final class OperationNotAllowedException extends AuthException {
  const OperationNotAllowedException()
    : super('This sign-in method is not enabled.');
}

/// Invalid credential exception
final class InvalidCredentialException extends AuthException {
  const InvalidCredentialException()
    : super('The provided credentials are invalid.');
}

/// Credential already in use exception
final class CredentialAlreadyInUseException extends AuthException {
  const CredentialAlreadyInUseException()
    : super('This credential is already associated with another account.');
}

/// Network request failed exception
final class NetworkRequestFailedException extends AuthException {
  const NetworkRequestFailedException()
    : super('Network error. Please check your connection and try again.');
}

/// Invalid password reset code exception
final class InvalidPasswordResetCodeException extends AuthException {
  const InvalidPasswordResetCodeException()
    : super('The password reset code is invalid or has expired.');
}

/// Expired password reset code exception
final class ExpiredPasswordResetCodeException extends AuthException {
  const ExpiredPasswordResetCodeException()
    : super('The password reset code has expired. Please request a new one.');
}

/// No current user exception
final class NoCurrentUserException extends AuthException {
  const NoCurrentUserException() : super('No user is currently signed in.');
}

/// User creation failed exception
final class UserCreationFailedException extends AuthException {
  const UserCreationFailedException()
    : super('Account creation failed. Please try again.');
}

/// Sign in failed exception
final class SignInFailedException extends AuthException {
  const SignInFailedException() : super('Sign in failed. Please try again.');
}

/// Unknown authentication exception
final class UnknownAuthException extends AuthException {
  const UnknownAuthException(super.message);
}
