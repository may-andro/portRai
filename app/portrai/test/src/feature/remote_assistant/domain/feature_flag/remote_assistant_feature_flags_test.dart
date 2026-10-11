import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/remote_assistant/domain/feature_flag/remote_assistant_feature_flags.dart';

void main() {
  test('should default the remote assistant rollout flag to disabled', () {
    expect(
      RemoteAssistantFeatureFlags.remoteAssistant.key,
      'feature_remote_assistant',
    );
    expect(RemoteAssistantFeatureFlags.remoteAssistant.defaultValue, isFalse);
  });

  test(
    'should list every remote assistant flag when enumerating definitions',
    () {
      expect(RemoteAssistantFeatureFlags.all, [
        RemoteAssistantFeatureFlags.remoteAssistant,
      ]);
    },
  );
}
