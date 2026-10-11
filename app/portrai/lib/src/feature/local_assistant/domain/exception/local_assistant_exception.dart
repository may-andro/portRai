sealed class LocalAssistantException implements Exception {
  const LocalAssistantException();
}

class LocalAssistantUnavailableException extends LocalAssistantException {
  const LocalAssistantUnavailableException();
}

class LocalAssistantFlagException extends LocalAssistantException {
  const LocalAssistantFlagException();
}

class LocalAssistantPreferenceException extends LocalAssistantException {
  const LocalAssistantPreferenceException();
}

class LocalAssistantCancelledException extends LocalAssistantException {
  const LocalAssistantCancelledException();
}

class LocalAssistantBusyException extends LocalAssistantException {
  const LocalAssistantBusyException();
}
