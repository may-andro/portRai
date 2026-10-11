import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

abstract final class RemoteAssistantFeatureFlags {
  static const remoteAssistant = AppFeatureFlagDefinition(
    key: 'feature_remote_assistant',
    defaultValue: false,
    displayName: 'Remote Assistant',
    description: 'Enables portfolio Q&A using Firebase AI.',
  );

  static const all = [remoteAssistant];
}
