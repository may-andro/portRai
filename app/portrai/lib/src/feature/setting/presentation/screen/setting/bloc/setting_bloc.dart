import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/onboarding/onboarding.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/feature/setting/domain/_domain.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_event.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_state.dart';

@register
class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc(
    this._isFeatureEnabledUseCase,
    this._buildConfig,
    this._isLocalAssistantSupportedUseCase,
    this._getGuestUserUseCase,
  ) : super(const SettingInitialState()) {
    on<LoadSettingsEvent>(_mapLoadSettingsEventToState);
  }

  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final BuildConfig _buildConfig;
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;
  final GetGuestUserUseCase _getGuestUserUseCase;
  int _loadRevision = 0;

  Future<void> _mapLoadSettingsEventToState(
    LoadSettingsEvent event,
    Emitter<SettingState> emit,
  ) async {
    final revision = ++_loadRevision;
    emit(const SettingLoadingState());

    final languageSelectorResult = await _isFeatureEnabledUseCase(
      SettingFeatureFlags.languageSelector,
    );

    var isLanguageSelectorEnabled =
        SettingFeatureFlags.languageSelector.defaultValue;
    if (languageSelectorResult.isRight) {
      isLanguageSelectorEnabled = languageSelectorResult.right;
    }

    final remote = await _isFeatureEnabledUseCase(
      RemoteAssistantFeatureFlags.remoteAssistant,
    );
    var isLocalAssistantAvailable = false;
    if (remote.isRight && !remote.right) {
      final local = await _isFeatureEnabledUseCase(
        LocalAssistantFeatureFlags.aiAssistant,
      );
      if (local.isRight && local.right) {
        final localSupported = await _isLocalAssistantSupportedUseCase();
        isLocalAssistantAvailable =
            localSupported.isRight && localSupported.right;
      }
    }

    UserRole? userRole;
    final onboarding = await _isFeatureEnabledUseCase(
      OnboardingFeatureFlags.roleOnboarding,
    );
    if (onboarding.isRight && onboarding.right) {
      final user = await _getGuestUserUseCase();
      userRole = user.isRight ? user.right?.role : null;
    }
    if (emit.isDone || revision != _loadRevision) return;
    emit(
      SettingLoadedState(
        isLanguageSelectorEnabled: isLanguageSelectorEnabled,
        isDevMenuEnabled: _buildConfig.buildEnvironment.isDevMenuEnabled,
        isLocalAssistantAvailable: isLocalAssistantAvailable,
        userRole: userRole,
      ),
    );
  }
}
