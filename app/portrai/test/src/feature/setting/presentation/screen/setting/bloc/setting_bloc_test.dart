import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/feature/setting/domain/feature_flag/setting_feature_flags.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_supported_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/domain/use_case/mock_is_remote_assistant_supported_use_case.dart';

void main() {
  group('SettingBloc', () {
    late MockIsFeatureEnabledUseCase isFeatureEnabledUseCase;
    late MockIsLocalAssistantSupportedUseCase local;
    late MockIsRemoteAssistantSupportedUseCase remote;

    SettingBloc buildBloc() => SettingBloc(
      isFeatureEnabledUseCase,
      BuildConfig(buildEnvironment: BuildEnvironment.prod),
      local,
      remote,
    );

    setUp(() {
      isFeatureEnabledUseCase = MockIsFeatureEnabledUseCase()
        ..stubCall(
          definition: LocalAssistantFeatureFlags.aiAssistant,
          result: const Right(false),
        )
        ..stubCall(
          definition: RemoteAssistantFeatureFlags.remoteAssistant,
          result: const Right(false),
        );
      local = MockIsLocalAssistantSupportedUseCase()..stubCall(true);
      remote = MockIsRemoteAssistantSupportedUseCase()..stubCall(true);
    });

    for (final localEnabled in [false, true]) {
      for (final remoteEnabled in [false, true]) {
        for (final localSupported in [false, true]) {
          for (final remoteSupported in [false, true]) {
            blocTest<SettingBloc, SettingState>(
              'should select only the active supported assistant when local=$localEnabled remote=$remoteEnabled localSupported=$localSupported remoteSupported=$remoteSupported',
              setUp: () {
                isFeatureEnabledUseCase
                  ..stubCall(
                    definition: SettingFeatureFlags.languageSelector,
                    result: const Right(false),
                  )
                  ..stubCall(
                    definition: LocalAssistantFeatureFlags.aiAssistant,
                    result: Right(localEnabled),
                  )
                  ..stubCall(
                    definition: RemoteAssistantFeatureFlags.remoteAssistant,
                    result: Right(remoteEnabled),
                  );
                local.stubCall(localSupported);
                remote.stubCall(remoteSupported);
              },
              build: buildBloc,
              act: (bloc) => bloc.add(const LoadSettingsEvent()),
              expect: () => [
                const SettingLoadingState(),
                SettingLoadedState(
                  isLanguageSelectorEnabled: false,
                  isLocalAssistantAvailable:
                      !remoteEnabled && localEnabled && localSupported,
                  isRemoteAssistantAvailable: remoteEnabled && remoteSupported,
                ),
              ],
            );
          }
        }
      }
    }

    blocTest<SettingBloc, SettingState>(
      'should hide both assistants when the remote rollout check fails',
      setUp: () {
        isFeatureEnabledUseCase
          ..stubCall(
            definition: SettingFeatureFlags.languageSelector,
            result: const Right(false),
          )
          ..stubCall(
            definition: LocalAssistantFeatureFlags.aiAssistant,
            result: const Right(true),
          )
          ..stubCall(
            definition: RemoteAssistantFeatureFlags.remoteAssistant,
            result: const Left(FeatureFlagUnknownFailure()),
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
      'should enable the developer menu when loading settings in staging',
      setUp: () {
        isFeatureEnabledUseCase.stubCall(
          definition: SettingFeatureFlags.languageSelector,
          result: const Right<IsFeatureEnabledFailure, bool>(false),
        );
      },
      build: () => SettingBloc(
        isFeatureEnabledUseCase,
        BuildConfig(buildEnvironment: BuildEnvironment.staging),
        local,
        remote,
      ),
      act: (bloc) => bloc.add(const LoadSettingsEvent()),
      expect: () => const [
        SettingLoadingState(),
        SettingLoadedState(
          isLanguageSelectorEnabled: false,
          isDevMenuEnabled: true,
        ),
      ],
    );

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
