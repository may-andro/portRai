import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';

void main() {
  for (final enabled in [false, true]) {
    for (final supported in [false, true]) {
      test(
        'should activate from flag and platform alone when enabled=$enabled supported=$supported',
        () async {
          final flag = MockIsFeatureEnabledUseCase()
            ..stubCall(
              definition: RemoteAssistantFeatureFlags.remoteAssistant,
              result: Right(enabled),
            );
          final result = await GetRemoteAssistantAvailabilityUseCase(
            flag,
            RemoteAssistantAvailability.supported(supported),
          )();
          expect(
            result.right,
            AssistantAvailabilityEntity(
              isFeatureEnabled: enabled,
              isSupported: supported,
            ),
          );
          expect(result.right.isAvailable, enabled && supported);
        },
      );
    }
  }

  test('should preserve a typed failure when flag resolution fails', () async {
    const failure = FeatureFlagUnknownFailure();
    final flag = MockIsFeatureEnabledUseCase()
      ..stubCall(
        definition: RemoteAssistantFeatureFlags.remoteAssistant,
        result: const Left(failure),
      );
    final result = await GetRemoteAssistantAvailabilityUseCase(
      flag,
      const RemoteAssistantAvailability.supported(true),
    )();
    expect(result.left, same(failure));
  });
}
