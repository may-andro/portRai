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
    AiNetworkException(:final serviceMessage) => RemoteAssistantNetworkFailure(
      cause: this,
      serviceMessage: serviceMessage,
    ),
    AiServerException(:final serviceMessage) => RemoteAssistantUnknownFailure(
      cause: this,
      serviceMessage: serviceMessage,
    ),
    AiTimeoutException() => RemoteAssistantTimeoutFailure(cause: this),
    RemoteAssistantTimeoutException() => const RemoteAssistantTimeoutFailure(),
    AiQuotaExceededException(:final serviceMessage) =>
      RemoteAssistantQuotaFailure(cause: this, serviceMessage: serviceMessage),
    AiConfigurationException(:final serviceMessage) ||
    AiUnsupportedLocationException(
      :final serviceMessage,
    ) => RemoteAssistantConfigurationFailure(
      cause: this,
      serviceMessage: serviceMessage,
    ),
    RemoteAssistantFlagException() =>
      const RemoteAssistantConfigurationFailure(),
    AiBlockedResponseException() => RemoteAssistantBlockedFailure(cause: this),
    AiInvalidInputException() => RemoteAssistantInvalidInputFailure(
      cause: this,
    ),
    RemoteAssistantInvalidInputException() =>
      const RemoteAssistantInvalidInputFailure(),
    AiEmptyResponseException() || AiIncompleteResponseException() =>
      RemoteAssistantIncompleteFailure(cause: this),
    RemoteAssistantIncompleteException() ||
    RemoteAssistantResponseLimitException() =>
      const RemoteAssistantIncompleteFailure(),
    RemoteAssistantCallbackException() => const RemoteAssistantUnknownFailure(),
    AiSdkException() => RemoteAssistantUnknownFailure(cause: this),
    _ => unknownFailure,
  };
}
