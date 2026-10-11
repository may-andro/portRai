import 'package:firebase/firebase.dart';
import 'package:portrai/src/feature/remote_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';

extension RemoteAssistantErrorExtension on Object {
  RemoteAssistantFailure toRemoteAssistantFailure({
    RemoteAssistantFailure unknownFailure =
        const RemoteAssistantUnknownFailure(),
  }) => switch (this) {
    RemoteAssistantUnavailableException() ||
    RemoteAssistantCancelledException() ||
    RemoteAssistantClosedException() ||
    RemoteAssistantConcurrentRequestException() =>
      const RemoteAssistantUnavailableFailure(),
    AiNetworkException() ||
    AiServerException() => const RemoteAssistantNetworkFailure(),
    AiTimeoutException() ||
    RemoteAssistantTimeoutException() => const RemoteAssistantTimeoutFailure(),
    AiQuotaExceededException() => const RemoteAssistantQuotaFailure(),
    AiConfigurationException() ||
    AiUnsupportedLocationException() ||
    RemoteAssistantFlagException() =>
      const RemoteAssistantConfigurationFailure(),
    AiBlockedResponseException() => const RemoteAssistantBlockedFailure(),
    AiInvalidInputException() || RemoteAssistantInvalidInputException() =>
      const RemoteAssistantInvalidInputFailure(),
    AiEmptyResponseException() ||
    AiIncompleteResponseException() ||
    RemoteAssistantIncompleteException() ||
    RemoteAssistantResponseLimitException() =>
      const RemoteAssistantIncompleteFailure(),
    RemoteAssistantCallbackException() ||
    AiSdkException() => const RemoteAssistantUnknownFailure(),
    _ => unknownFailure,
  };
}
