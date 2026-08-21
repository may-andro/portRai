import 'package:core/core.dart';

sealed class ExpertiseException implements AppException {
  const ExpertiseException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'ExpertiseException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class ExpertiseNotFoundException extends ExpertiseException {
  const ExpertiseNotFoundException({super.cause, super.stackTrace});
}

class ExpertiseNetworkException extends ExpertiseException {
  const ExpertiseNetworkException({super.cause, super.stackTrace});
}

class ExpertiseParsingException extends ExpertiseException {
  const ExpertiseParsingException({super.cause, super.stackTrace});
}

class ExpertiseUnauthorizedException extends ExpertiseException {
  const ExpertiseUnauthorizedException({super.cause, super.stackTrace});
}

class ExpertiseCacheException extends ExpertiseException {
  const ExpertiseCacheException({super.cause, super.stackTrace});
}
