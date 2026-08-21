import 'package:core/core.dart';

sealed class ProfileException implements AppException {
  const ProfileException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'ProfileException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class ProfileNotFoundException extends ProfileException {
  const ProfileNotFoundException({super.cause, super.stackTrace});
}

class ProfileNetworkException extends ProfileException {
  const ProfileNetworkException({super.cause, super.stackTrace});
}

class ProfileParsingException extends ProfileException {
  const ProfileParsingException({super.cause, super.stackTrace});
}

class ProfileUnauthorizedException extends ProfileException {
  const ProfileUnauthorizedException({super.cause, super.stackTrace});
}

class ProfileCacheException extends ProfileException {
  const ProfileCacheException({super.cause, super.stackTrace});
}
