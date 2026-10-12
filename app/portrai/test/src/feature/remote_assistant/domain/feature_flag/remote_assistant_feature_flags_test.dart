import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/remote_assistant/domain/feature_flag/remote_assistant_feature_flags.dart';

void main() {
  test('should default the remote assistant flags to disabled', () {
    expect(
      RemoteAssistantFeatureFlags.remoteAssistant.key,
      'feature_remote_assistant',
    );
    expect(RemoteAssistantFeatureFlags.remoteAssistant.defaultValue, isFalse);
    expect(
      RemoteAssistantFeatureFlags.generativeUi.key,
      'feature_remote_assistant_generative_ui',
    );
    expect(RemoteAssistantFeatureFlags.generativeUi.defaultValue, isFalse);
  });

  test(
    'should list every remote assistant flag when enumerating definitions',
    () {
      expect(RemoteAssistantFeatureFlags.all, [
        RemoteAssistantFeatureFlags.remoteAssistant,
        RemoteAssistantFeatureFlags.generativeUi,
      ]);
    },
  );
}
