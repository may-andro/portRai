import 'package:use_case/use_case.dart';

sealed class RemoteAssistantFailure extends BasicFailure {
  const RemoteAssistantFailure({super.cause});
}

@Localizable('errorRemoteAssistantUnavailable')
class RemoteAssistantUnavailableFailure extends RemoteAssistantFailure {
  const RemoteAssistantUnavailableFailure({super.cause});
}

@Localizable('errorRemoteAssistantNetwork')
class RemoteAssistantNetworkFailure extends RemoteAssistantFailure {
  const RemoteAssistantNetworkFailure({super.cause});
}

@Localizable('errorRemoteAssistantTimeout')
class RemoteAssistantTimeoutFailure extends RemoteAssistantFailure {
  const RemoteAssistantTimeoutFailure({super.cause});
}

@Localizable('errorRemoteAssistantQuota')
class RemoteAssistantQuotaFailure extends RemoteAssistantFailure {
  const RemoteAssistantQuotaFailure({super.cause});
}

@Localizable('errorRemoteAssistantConfiguration')
class RemoteAssistantConfigurationFailure extends RemoteAssistantFailure {
  const RemoteAssistantConfigurationFailure({super.cause});
}

@Localizable('errorRemoteAssistantBlocked')
class RemoteAssistantBlockedFailure extends RemoteAssistantFailure {
  const RemoteAssistantBlockedFailure({super.cause});
}

@Localizable('errorRemoteAssistantInvalidInput')
class RemoteAssistantInvalidInputFailure extends RemoteAssistantFailure {
  const RemoteAssistantInvalidInputFailure({super.cause});
}

@Localizable('errorRemoteAssistantIncomplete')
class RemoteAssistantIncompleteFailure extends RemoteAssistantFailure {
  const RemoteAssistantIncompleteFailure({super.cause});
}

@Localizable('errorRemoteAssistantUnknown')
class RemoteAssistantUnknownFailure extends RemoteAssistantFailure {
  const RemoteAssistantUnknownFailure({super.cause});
}
