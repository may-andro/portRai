import 'package:portrai/src/feature/assistant/assistant.dart';

abstract interface class RemoteAssistantRepository {
  Future<void> resetSession();

  Future<void> answer({
    required String question,
    required String portfolioContext,
    required List<AssistantMessageEntity> history,
    required void Function(String delta) onDelta,
  });

  Future<void> close();
}
