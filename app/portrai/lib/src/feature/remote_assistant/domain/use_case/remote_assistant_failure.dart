import 'package:use_case/use_case.dart';

sealed class RemoteAssistantFailure extends BasicFailure {
  const RemoteAssistantFailure({super.cause, this.serviceMessage});

  /// Optional backend error details supplement, never replace, localization.
  /// Excluded from inherited failure logging and equality properties.
  final String? serviceMessage;
}

@Localizable('errorRemoteAssistantUnavailable')
class RemoteAssistantUnavailableFailure extends RemoteAssistantFailure {
  const RemoteAssistantUnavailableFailure({super.cause, super.serviceMessage});
}

@Localizable('errorRemoteAssistantNetwork')
class RemoteAssistantNetworkFailure extends RemoteAssistantFailure {
  const RemoteAssistantNetworkFailure({super.cause, super.serviceMessage});
}

@Localizable('errorRemoteAssistantTimeout')
class RemoteAssistantTimeoutFailure extends RemoteAssistantFailure {
  const RemoteAssistantTimeoutFailure({super.cause, super.serviceMessage});
}

@Localizable('errorRemoteAssistantQuota')
class RemoteAssistantQuotaFailure extends RemoteAssistantFailure {
  const RemoteAssistantQuotaFailure({super.cause, super.serviceMessage});
}

@Localizable('errorRemoteAssistantConfiguration')
class RemoteAssistantConfigurationFailure extends RemoteAssistantFailure {
  const RemoteAssistantConfigurationFailure({
    super.cause,
    super.serviceMessage,
  });
}

@Localizable('errorRemoteAssistantBlocked')
class RemoteAssistantBlockedFailure extends RemoteAssistantFailure {
  const RemoteAssistantBlockedFailure({super.cause, super.serviceMessage});
}

@Localizable('errorRemoteAssistantInvalidInput')
class RemoteAssistantInvalidInputFailure extends RemoteAssistantFailure {
  const RemoteAssistantInvalidInputFailure({super.cause, super.serviceMessage});
}

@Localizable('errorRemoteAssistantIncomplete')
class RemoteAssistantIncompleteFailure extends RemoteAssistantFailure {
  const RemoteAssistantIncompleteFailure({super.cause, super.serviceMessage});
}

@Localizable('errorRemoteAssistantUnknown')
class RemoteAssistantUnknownFailure extends RemoteAssistantFailure {
  const RemoteAssistantUnknownFailure({super.cause, super.serviceMessage});
}
