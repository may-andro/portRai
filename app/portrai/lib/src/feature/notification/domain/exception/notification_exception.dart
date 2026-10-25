import 'package:core/core.dart';

sealed class NotificationException implements AppException {
  const NotificationException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'NotificationException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

/// Reading or deleting this device's token failed.
class NotificationTokenException extends NotificationException {
  const NotificationTokenException({super.cause, super.stackTrace});
}

/// Subscribing to or unsubscribing from a topic failed.
class NotificationTopicException extends NotificationException {
  const NotificationTopicException({super.cause, super.stackTrace});
}

/// Registering this device for the signed-in user failed.
class NotificationDeviceException extends NotificationException {
  const NotificationDeviceException({super.cause, super.stackTrace});
}
