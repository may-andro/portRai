import 'package:portrai/src/feature/local_assistant/domain/exception/_exception.dart';
import 'package:use_case/use_case.dart';

sealed class LocalAssistantFailure extends BasicFailure {
  const LocalAssistantFailure({super.cause});
}

@Localizable('assistantError')
class UnknownLocalAssistantFailure extends LocalAssistantFailure {
  const UnknownLocalAssistantFailure({super.cause});
}

@Localizable('errorLocalAssistantUnavailable')
class UnavailableLocalAssistantFailure extends LocalAssistantFailure {
  const UnavailableLocalAssistantFailure({super.cause});
}

@Localizable('errorLocalAssistantBusy')
class BusyLocalAssistantFailure extends LocalAssistantFailure {
  const BusyLocalAssistantFailure({super.cause});
}

extension LocalAssistantErrorExtension on Object {
  LocalAssistantFailure get toLocalAssistantFailure => switch (this) {
    LocalAssistantBusyException() => BusyLocalAssistantFailure(cause: this),
    LocalAssistantUnavailableException() ||
    LocalAssistantCancelledException() => UnavailableLocalAssistantFailure(
      cause: this,
    ),
    _ => UnknownLocalAssistantFailure(cause: this),
  };
}
