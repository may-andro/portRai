import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

/// Local rollout retains its existing Remote Config key.
abstract final class LocalAssistantFeatureFlags {
  static const aiAssistant = AppFeatureFlagDefinition(
    key: 'feature_ai_assistant',
    defaultValue: false,
    displayName: 'AI Assistant',
    description:
        'Shows the on-device AI assistant in settings and on the portfolio',
  );

  static const all = [aiAssistant];
}
