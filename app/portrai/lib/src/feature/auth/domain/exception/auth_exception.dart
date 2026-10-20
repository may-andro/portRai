import 'package:core/core.dart';

sealed class AuthException implements AppException {
  const AuthException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'AuthException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

/// Wrong email or password. Covers an unknown or disabled account too, so the
/// sign-in screen never reveals which accounts exist.
class AuthInvalidCredentialsException extends AuthException {
  const AuthInvalidCredentialsException({super.cause, super.stackTrace});
}

class AuthTooManyRequestsException extends AuthException {
  const AuthTooManyRequestsException({super.cause, super.stackTrace});
}

class AuthNetworkException extends AuthException {
  const AuthNetworkException({super.cause, super.stackTrace});
}

class AuthUnknownException extends AuthException {
  const AuthUnknownException({super.cause, super.stackTrace});
}
