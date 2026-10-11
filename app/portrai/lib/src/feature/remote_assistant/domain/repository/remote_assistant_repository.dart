import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/entity/remote_assistant_preference_entity.dart';

abstract interface class RemoteAssistantRepository {
  Future<RemoteAssistantPreferenceEntity> getPreference();

  Future<void> updatePreference(RemoteAssistantPreferenceEntity preference);

  Future<void> resetSession();

  Future<void> answer({
    required String question,
    required String portfolioContext,
    required List<AssistantMessageEntity> history,
    required void Function(String delta) onDelta,
  });

  Future<void> close();
}
