import 'package:core/core.dart';

sealed class JobOpeningException implements AppException {
  const JobOpeningException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'JobOpeningException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class JobOpeningNotFoundException extends JobOpeningException {
  const JobOpeningNotFoundException({super.cause, super.stackTrace});
}

/// Firestore rules refused the read or write, for example for another
/// user's data.
class JobOpeningPermissionDeniedException extends JobOpeningException {
  const JobOpeningPermissionDeniedException({super.cause, super.stackTrace});
}

class JobOpeningNetworkException extends JobOpeningException {
  const JobOpeningNetworkException({super.cause, super.stackTrace});
}

class JobOpeningParsingException extends JobOpeningException {
  const JobOpeningParsingException({super.cause, super.stackTrace});
}

class JobOpeningUnknownException extends JobOpeningException {
  const JobOpeningUnknownException({super.cause, super.stackTrace});
}
