import 'package:core/core.dart';

sealed class MessagingException implements AppException {
  const MessagingException(this.message, this.cause, this.stackTrace);

  final String message;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() => 'MessagingException: $message';
}

class MessagingPermissionException extends MessagingException {
  const MessagingPermissionException(Object cause, StackTrace stackTrace)
    : super('Reading or requesting the permission failed', cause, stackTrace);
}

class MessagingTokenException extends MessagingException {
  const MessagingTokenException(Object cause, StackTrace stackTrace)
    : super('Reading or deleting the token failed', cause, stackTrace);
}

class MessagingTopicException extends MessagingException {
  const MessagingTopicException(
    String topic,
    Object cause,
    StackTrace stackTrace,
  ) : super('Changing the subscription to $topic failed', cause, stackTrace);
}
