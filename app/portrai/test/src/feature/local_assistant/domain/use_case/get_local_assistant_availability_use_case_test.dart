import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';

import '../../../../../mock/feature/feature_flag/domain/repository/mock_app_feature_flag_repository.dart';

void main() {
  for (final enabled in [false, true]) {
    for (final supported in [false, true]) {
      test(
        'should expose a domain availability snapshot when enabled=$enabled supported=$supported',
        () async {
          final repository = MockAppFeatureFlagRepository()
            ..stubIsFeatureEnabled(
              definition: LocalAssistantFeatureFlags.aiAssistant,
              isEnabled: enabled,
            );
          final result = await GetLocalAssistantAvailabilityUseCase(
            IsFeatureEnabledUseCase(repository),
            LocalAssistantAvailability.supported(supported),
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
    final repository = MockAppFeatureFlagRepository()
      ..stubIsFeatureEnabledThrows(
        definition: LocalAssistantFeatureFlags.aiAssistant,
        error: StateError('Flag unavailable'),
      );
    final result = await GetLocalAssistantAvailabilityUseCase(
      IsFeatureEnabledUseCase(repository),
      const LocalAssistantAvailability.supported(true),
    )();
    expect(result.left, isA<FeatureFlagUnknownFailure>());
  });
}
