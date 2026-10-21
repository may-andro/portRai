import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../mock/feature/remote_assistant/domain/use_case/mock_is_remote_assistant_supported_use_case.dart';

void main() {
  group('IsJobOpeningInsightsAvailableUseCase', () {
    late MockIsFeatureEnabledUseCase isFeatureEnabledUseCase;
    late MockIsRemoteAssistantSupportedUseCase
    isRemoteAssistantSupportedUseCase;
    late IsJobOpeningInsightsAvailableUseCase useCase;

    void stubFlags({
      Either<IsFeatureEnabledFailure, bool> insights = const Right(true),
      Either<IsFeatureEnabledFailure, bool> remoteAssistant = const Right(true),
    }) {
      isFeatureEnabledUseCase
        ..stubCall(
          definition: JobOpeningFeatureFlags.insights,
          result: insights,
        )
        ..stubCall(
          definition: RemoteAssistantFeatureFlags.remoteAssistant,
          result: remoteAssistant,
        );
    }

    setUp(() {
      isFeatureEnabledUseCase = MockIsFeatureEnabledUseCase();
      isRemoteAssistantSupportedUseCase =
          MockIsRemoteAssistantSupportedUseCase()..stubCall(const Right(true));
      useCase = IsJobOpeningInsightsAvailableUseCase(
        isFeatureEnabledUseCase,
        isRemoteAssistantSupportedUseCase,
      );
    });

    test('should be available when both flags are on and the platform '
        'supports the assistant', () async {
      stubFlags();

      expect(await useCase(), const Right<NoFailure, bool>(true));
    });

    test('should be unavailable when the insights flag is off', () async {
      stubFlags(insights: const Right(false));

      expect(await useCase(), const Right<NoFailure, bool>(false));
    });

    test(
      'should be unavailable when the remote assistant flag is off',
      () async {
        stubFlags(remoteAssistant: const Right(false));

        expect(await useCase(), const Right<NoFailure, bool>(false));
      },
    );

    test('should be unavailable when a flag cannot be read', () async {
      stubFlags(insights: const Left(FeatureFlagUnknownFailure()));

      expect(await useCase(), const Right<NoFailure, bool>(false));
    });

    test('should be unavailable when the platform does not support the '
        'assistant', () async {
      stubFlags();
      isRemoteAssistantSupportedUseCase.stubCall(const Right(false));

      expect(await useCase(), const Right<NoFailure, bool>(false));
    });
  });
}
