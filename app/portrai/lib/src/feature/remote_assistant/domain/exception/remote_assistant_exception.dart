import 'package:core/core.dart';

sealed class RemoteAssistantException implements AppException {
  const RemoteAssistantException();

  @override
  String toString() => 'RemoteAssistantException: operation failed';
}

class RemoteAssistantClosedException extends RemoteAssistantException {
  const RemoteAssistantClosedException();
}

class RemoteAssistantConcurrentRequestException
    extends RemoteAssistantException {
  const RemoteAssistantConcurrentRequestException();
}

class RemoteAssistantFlagException extends RemoteAssistantException {
  const RemoteAssistantFlagException();
}

class RemoteAssistantUnavailableException extends RemoteAssistantException {
  const RemoteAssistantUnavailableException();
}

class RemoteAssistantInvalidInputException extends RemoteAssistantException {
  const RemoteAssistantInvalidInputException();
}

class RemoteAssistantTimeoutException extends RemoteAssistantException {
  const RemoteAssistantTimeoutException();
}

class RemoteAssistantCancelledException extends RemoteAssistantException {
  const RemoteAssistantCancelledException();
}

class RemoteAssistantCallbackException extends RemoteAssistantException {
  const RemoteAssistantCallbackException();
}

class RemoteAssistantIncompleteException extends RemoteAssistantException {
  const RemoteAssistantIncompleteException();
}

class RemoteAssistantResponseLimitException extends RemoteAssistantException {
  const RemoteAssistantResponseLimitException();
}
