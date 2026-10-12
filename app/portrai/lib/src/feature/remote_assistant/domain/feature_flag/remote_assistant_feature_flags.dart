import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

abstract final class RemoteAssistantFeatureFlags {
  static const remoteAssistant = AppFeatureFlagDefinition(
    key: 'feature_remote_assistant',
    defaultValue: false,
    displayName: 'Remote Assistant',
    description: 'Enables portfolio Q&A using Firebase AI.',
  );

  static const generativeUi = AppFeatureFlagDefinition(
    key: 'feature_remote_assistant_generative_ui',
    defaultValue: false,
    displayName: 'Remote Assistant Generative UI',
    description:
        'Enables read-only design-system components in remote answers.',
  );

  static const all = [remoteAssistant, generativeUi];
}
