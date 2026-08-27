import 'package:core/core.dart';

sealed class AppConfigException implements AppException {
  const AppConfigException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'AppConfigException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class AppConfigNotFoundException extends AppConfigException {
  const AppConfigNotFoundException({super.cause, super.stackTrace});
}

class AppConfigNetworkException extends AppConfigException {
  const AppConfigNetworkException({super.cause, super.stackTrace});
}

class AppConfigParsingException extends AppConfigException {
  const AppConfigParsingException({super.cause, super.stackTrace});
}

class AppConfigUnauthorizedException extends AppConfigException {
  const AppConfigUnauthorizedException({super.cause, super.stackTrace});
}

class AppConfigCacheException extends AppConfigException {
  const AppConfigCacheException({super.cause, super.stackTrace});
}
