import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

/// Feature flags owned by the `assistant` feature.
abstract final class AssistantFeatureFlags {
  static const aiAssistant = AppFeatureFlagDefinition(
    key: 'feature_ai_assistant',
    defaultValue: true,
    displayName: 'AI Assistant',
    description:
        'Shows the on-device AI assistant in settings and on the portfolio',
  );

  static const all = [aiAssistant];
}
