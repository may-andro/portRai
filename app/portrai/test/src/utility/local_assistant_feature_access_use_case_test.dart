import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/utility/local_assistant_feature_access_use_case.dart';

import '../../mock/feature/feature_flag/domain/repository/mock_app_feature_flag_repository.dart';

void main() {
  for (final (local, remote) in [
    (false, false),
    (true, false),
    (false, true),
    (true, true),
  ]) {
    test(
      'should allow local=${local && !remote} without mutations when flags are local=$local remote=$remote',
      () async {
        final repository = MockAppFeatureFlagRepository()
          ..stubIsFeatureEnabled(
            definition: LocalAssistantFeatureFlags.aiAssistant,
            isEnabled: local,
          )
          ..stubIsFeatureEnabled(
            definition: RemoteAssistantFeatureFlags.remoteAssistant,
            isEnabled: remote,
          );
        final useCase = LocalAssistantFeatureAccessUseCase(repository);
        final result = await useCase(LocalAssistantFeatureFlags.aiAssistant);
        expect(result.right, local && !remote);
        verifyNever(repository.reset);
      },
    );
  }

  test('should fail closed when remote flag resolution throws', () async {
    final repository = MockAppFeatureFlagRepository()
      ..stubIsFeatureEnabledThrows(
        definition: RemoteAssistantFeatureFlags.remoteAssistant,
        error: StateError('Flag unavailable'),
      );
    final result = await LocalAssistantFeatureAccessUseCase(repository)(
      LocalAssistantFeatureFlags.aiAssistant,
    );
    expect(result.left, isA<FeatureFlagUnknownFailure>());
    verifyNever(
      () => repository.isFeatureEnabled(LocalAssistantFeatureFlags.aiAssistant),
    );
  });
}
