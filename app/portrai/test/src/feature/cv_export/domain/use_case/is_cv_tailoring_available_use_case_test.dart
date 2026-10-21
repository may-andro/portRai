import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../mock/feature/remote_assistant/domain/use_case/mock_is_remote_assistant_supported_use_case.dart';

void main() {
  group('IsCvTailoringAvailableUseCase', () {
    late MockIsFeatureEnabledUseCase isFeatureEnabledUseCase;
    late MockIsRemoteAssistantSupportedUseCase
    isRemoteAssistantSupportedUseCase;
    late IsCvTailoringAvailableUseCase useCase;

    void stubFlag(Either<IsFeatureEnabledFailure, bool> result) =>
        isFeatureEnabledUseCase.stubCall(
          definition: CvExportFeatureFlags.tailoredCv,
          result: result,
        );

    setUp(() {
      isFeatureEnabledUseCase = MockIsFeatureEnabledUseCase();
      isRemoteAssistantSupportedUseCase =
          MockIsRemoteAssistantSupportedUseCase()..stubCall(const Right(true));
      useCase = IsCvTailoringAvailableUseCase(
        isFeatureEnabledUseCase,
        isRemoteAssistantSupportedUseCase,
      );
    });

    test('should be available when the flag is on and the platform is '
        'supported', () async {
      stubFlag(const Right(true));

      expect(await useCase(), const Right<NoFailure, bool>(true));
    });

    test('should be unavailable when the flag is off', () async {
      stubFlag(const Right(false));

      expect(await useCase(), const Right<NoFailure, bool>(false));
    });

    test('should be unavailable when the flag cannot be read', () async {
      stubFlag(const Left(FeatureFlagUnknownFailure()));

      expect(await useCase(), const Right<NoFailure, bool>(false));
    });

    test('should be unavailable when the platform is not supported', () async {
      stubFlag(const Right(true));
      isRemoteAssistantSupportedUseCase.stubCall(const Right(false));

      expect(await useCase(), const Right<NoFailure, bool>(false));
    });
  });
}
