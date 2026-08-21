import 'package:core/core.dart';

sealed class ExperienceException implements AppException {
  const ExperienceException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'ExperienceException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class ExperienceNotFoundException extends ExperienceException {
  const ExperienceNotFoundException({super.cause, super.stackTrace});
}

class ExperienceNetworkException extends ExperienceException {
  const ExperienceNetworkException({super.cause, super.stackTrace});
}

class ExperienceParsingException extends ExperienceException {
  const ExperienceParsingException({super.cause, super.stackTrace});
}

class ExperienceUnauthorizedException extends ExperienceException {
  const ExperienceUnauthorizedException({super.cause, super.stackTrace});
}

class ExperienceCacheException extends ExperienceException {
  const ExperienceCacheException({super.cause, super.stackTrace});
}
