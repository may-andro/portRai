import 'package:use_case/use_case.dart';

sealed class LocalAssistantFailure extends BasicFailure {
  const LocalAssistantFailure({super.cause});
}

class UnknownLocalAssistantFailure extends LocalAssistantFailure {
  const UnknownLocalAssistantFailure({super.cause});
}
