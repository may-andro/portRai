import 'package:cloud_functions/cloud_functions.dart';
import 'package:core/core.dart';

// Base Firebase Functions exception
sealed class FunctionException implements AppException {
  const FunctionException(this.message, this.cause, this.stackTrace);

  final String message;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() => 'FunctionException: $message';
}

// Specific exception types
class FunctionAuthenticationException extends FunctionException {
  const FunctionAuthenticationException(Object cause, StackTrace stackTrace)
    : super('User not authenticated for function call', cause, stackTrace);
}

class FunctionPermissionDeniedException extends FunctionException {
  const FunctionPermissionDeniedException(
    String functionName,
    Object cause,
    StackTrace stackTrace,
  ) : super('Permission denied for function: $functionName', cause, stackTrace);
}

class FunctionNotFoundException extends FunctionException {
  const FunctionNotFoundException(
    String functionName,
    Object cause,
    StackTrace stackTrace,
  ) : super('Function not found: $functionName', cause, stackTrace);
}

class FunctionInvalidArgumentException extends FunctionException {
  const FunctionInvalidArgumentException(
    String functionName,
    String details,
    Object cause,
    StackTrace stackTrace,
  ) : super(
        'Invalid arguments for function $functionName: $details',
        cause,
        stackTrace,
      );
}

class FunctionTimeoutException extends FunctionException {
  const FunctionTimeoutException(
    String functionName,
    Object cause,
    StackTrace stackTrace,
  ) : super('Function call timed out: $functionName', cause, stackTrace);
}

class FunctionNetworkException extends FunctionException {
  const FunctionNetworkException(
    String functionName,
    Object cause,
    StackTrace stackTrace,
  ) : super('Network error calling function: $functionName', cause, stackTrace);
}

class FunctionQuotaExceededException extends FunctionException {
  const FunctionQuotaExceededException(Object cause, StackTrace stackTrace)
    : super('Firebase Functions quota exceeded', cause, stackTrace);
}

class FunctionInternalErrorException extends FunctionException {
  const FunctionInternalErrorException(
    String functionName,
    String details,
    Object cause,
    StackTrace stackTrace,
  ) : super(
        'Internal error in function $functionName: $details',
        cause,
        stackTrace,
      );
}

class FunctionEmptyResponseException extends FunctionException {
  const FunctionEmptyResponseException(
    String functionName,
    Object cause,
    StackTrace stackTrace,
  ) : super(
        'Function returned empty response: $functionName',
        cause,
        stackTrace,
      );
}

class FunctionUnknownException extends FunctionException {
  const FunctionUnknownException(
    String functionName,
    Object cause,
    StackTrace stackTrace,
  ) : super('Unknown error calling function: $functionName', cause, stackTrace);
}

/// Helper method to handle Firebase Functions exceptions consistently
FunctionException handleFunctionException(
  Object error,
  StackTrace stackTrace,
  String functionName,
) {
  if (error is FirebaseFunctionsException) {
    switch (error.code) {
      case 'unauthenticated':
        return FunctionAuthenticationException(error, stackTrace);
      case 'permission-denied':
        return FunctionPermissionDeniedException(
          functionName,
          error,
          stackTrace,
        );
      case 'not-found':
        return FunctionNotFoundException(functionName, error, stackTrace);
      case 'invalid-argument':
        return FunctionInvalidArgumentException(
          functionName,
          error.message ?? 'Invalid arguments provided',
          error,
          stackTrace,
        );
      case 'deadline-exceeded':
        return FunctionTimeoutException(functionName, error, stackTrace);
      case 'unavailable':
        return FunctionNetworkException(functionName, error, stackTrace);
      case 'resource-exhausted':
        return FunctionQuotaExceededException(error, stackTrace);
      case 'internal':
      case 'unknown':
        return FunctionInternalErrorException(
          functionName,
          error.message ?? 'Internal server error',
          error,
          stackTrace,
        );
      case 'failed-precondition':
      case 'out-of-range':
        return FunctionInvalidArgumentException(
          functionName,
          error.message ?? 'Function precondition failed',
          error,
          stackTrace,
        );
      default:
        return FunctionUnknownException(functionName, error, stackTrace);
    }
  }

  // Handle network-related exceptions
  if (error.toString().contains('network') ||
      error.toString().contains('connection') ||
      error.toString().contains('timeout')) {
    return FunctionNetworkException(functionName, error, stackTrace);
  }

  return FunctionUnknownException(functionName, error, stackTrace);
}
