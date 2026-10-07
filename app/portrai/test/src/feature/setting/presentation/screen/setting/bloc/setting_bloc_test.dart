import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/setting/domain/feature_flag/setting_feature_flags.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';

void main() {
  group('SettingBloc', () {
    late MockIsFeatureEnabledUseCase isFeatureEnabledUseCase;

    SettingBloc buildBloc() => SettingBloc(isFeatureEnabledUseCase);

    setUp(() {
      isFeatureEnabledUseCase = MockIsFeatureEnabledUseCase();
    });

    blocTest<SettingBloc, SettingState>(
      'should emit a loaded state with the flag value when loading succeeds',
      setUp: () {
        isFeatureEnabledUseCase.stubCall(
          definition: SettingFeatureFlags.languageSelector,
          result: const Right<IsFeatureEnabledFailure, bool>(true),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadSettingsEvent()),
      expect: () => const [
        SettingLoadingState(),
        SettingLoadedState(isLanguageSelectorEnabled: true),
      ],
    );

    blocTest<SettingBloc, SettingState>(
      'should emit a loaded state with the disabled flag value when loading succeeds with false',
      setUp: () {
        isFeatureEnabledUseCase.stubCall(
          definition: SettingFeatureFlags.languageSelector,
          result: const Right<IsFeatureEnabledFailure, bool>(false),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadSettingsEvent()),
      expect: () => const [
        SettingLoadingState(),
        SettingLoadedState(isLanguageSelectorEnabled: false),
      ],
    );

    blocTest<SettingBloc, SettingState>(
      'should emit a loaded state with the default value when checking the flag fails',
      setUp: () {
        isFeatureEnabledUseCase.stubCall(
          definition: SettingFeatureFlags.languageSelector,
          result: const Left<IsFeatureEnabledFailure, bool>(
            FeatureFlagUnknownFailure(),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadSettingsEvent()),
      expect: () => [
        const SettingLoadingState(),
        SettingLoadedState(
          isLanguageSelectorEnabled:
              SettingFeatureFlags.languageSelector.defaultValue,
        ),
      ],
    );
  });
}
