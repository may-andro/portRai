import 'package:core/core.dart';

sealed class ServiceException implements AppException {
  const ServiceException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'ServiceException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class ServiceNotFoundException extends ServiceException {
  const ServiceNotFoundException({super.cause, super.stackTrace});
}

class ServiceNetworkException extends ServiceException {
  const ServiceNetworkException({super.cause, super.stackTrace});
}

class ServiceParsingException extends ServiceException {
  const ServiceParsingException({super.cause, super.stackTrace});
}

class ServiceUnauthorizedException extends ServiceException {
  const ServiceUnauthorizedException({super.cause, super.stackTrace});
}

class ServiceCacheException extends ServiceException {
  const ServiceCacheException({super.cause, super.stackTrace});
}
