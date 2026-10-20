import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/onboarding/onboarding.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/feature/setting/domain/feature_flag/setting_feature_flags.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_supported_use_case.dart';
import '../../../../../../../mock/feature/user/domain/use_case/mock_get_guest_user_use_case.dart';

void main() {
  group('SettingBloc', () {
    late MockIsFeatureEnabledUseCase isFeatureEnabledUseCase;
    late MockIsLocalAssistantSupportedUseCase local;
    late MockGetGuestUserUseCase getGuestUserUseCase;

    SettingBloc buildBloc() => SettingBloc(
      isFeatureEnabledUseCase,
      BuildConfig(buildEnvironment: BuildEnvironment.prod),
      local,
      getGuestUserUseCase,
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
        )
        ..stubCall(
          definition: OnboardingFeatureFlags.roleOnboarding,
          result: const Right(false),
        );
      getGuestUserUseCase = MockGetGuestUserUseCase()..stubCall(null);
      local = MockIsLocalAssistantSupportedUseCase()..stubCall(true);
    });

    for (final localEnabled in [false, true]) {
      for (final remoteEnabled in [false, true]) {
        for (final localSupported in [false, true]) {
          blocTest<SettingBloc, SettingState>(
            'should offer only local model management when local=$localEnabled remote=$remoteEnabled localSupported=$localSupported',
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
            },
            build: buildBloc,
            act: (bloc) => bloc.add(const LoadSettingsEvent()),
            expect: () => [
              const SettingLoadingState(),
              SettingLoadedState(
                isLanguageSelectorEnabled: false,
                isLocalAssistantAvailable:
                    !remoteEnabled && localEnabled && localSupported,
              ),
            ],
            verify: (_) {
              if (remoteEnabled) {
                verifyNever(
                  () => isFeatureEnabledUseCase(
                    LocalAssistantFeatureFlags.aiAssistant,
                  ),
                );
                verifyNever(() => local());
              } else if (!localEnabled) {
                verify(
                  () => isFeatureEnabledUseCase(
                    LocalAssistantFeatureFlags.aiAssistant,
                  ),
                ).called(1);
                verifyNever(() => local());
              } else {
                verify(() => local()).called(1);
              }
            },
          );
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
      verify: (_) {
        verifyNever(
          () => isFeatureEnabledUseCase(LocalAssistantFeatureFlags.aiAssistant),
        );
        verifyNever(() => local());
      },
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
        getGuestUserUseCase,
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
    blocTest<SettingBloc, SettingState>(
      'should expose the saved role when role onboarding is enabled',
      setUp: () {
        isFeatureEnabledUseCase
          ..stubCall(
            definition: SettingFeatureFlags.languageSelector,
            result: const Right(false),
          )
          ..stubCall(
            definition: OnboardingFeatureFlags.roleOnboarding,
            result: const Right(true),
          );
        getGuestUserUseCase.stubCall(
          const GuestUserEntity(role: UserRole.recruiter),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadSettingsEvent()),
      expect: () => const [
        SettingLoadingState(),
        SettingLoadedState(
          isLanguageSelectorEnabled: false,
          userRole: UserRole.recruiter,
        ),
      ],
    );

    blocTest<SettingBloc, SettingState>(
      'should not expose a role when role onboarding is disabled',
      setUp: () {
        isFeatureEnabledUseCase.stubCall(
          definition: SettingFeatureFlags.languageSelector,
          result: const Right(false),
        );
        getGuestUserUseCase.stubCall(
          const GuestUserEntity(role: UserRole.developer),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadSettingsEvent()),
      expect: () => const [
        SettingLoadingState(),
        SettingLoadedState(isLanguageSelectorEnabled: false),
      ],
    );
  });
}
