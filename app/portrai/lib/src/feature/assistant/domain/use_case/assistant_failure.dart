import 'package:use_case/use_case.dart';

sealed class AssistantFailure extends BasicFailure {
  const AssistantFailure({super.cause});
}

class UnknownAssistantFailure extends AssistantFailure {
  const UnknownAssistantFailure({super.cause});
}
