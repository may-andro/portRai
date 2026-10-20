import 'package:core/core.dart';

sealed class AiRateLimitException implements AppException {
  const AiRateLimitException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'AiRateLimitException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class AiRequestLogCacheException extends AiRateLimitException {
  const AiRequestLogCacheException({super.cause, super.stackTrace});
}
