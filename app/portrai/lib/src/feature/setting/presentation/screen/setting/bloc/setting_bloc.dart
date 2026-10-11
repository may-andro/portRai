import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/feature/setting/domain/_domain.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_event.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_state.dart';

@register
class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc(
    this._isFeatureEnabledUseCase,
    this._buildConfig,
    this._getLocalAvailability,
    this._getRemoteAvailability,
  ) : super(const SettingInitialState()) {
    on<LoadSettingsEvent>(_mapLoadSettingsEventToState);
  }

  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final BuildConfig _buildConfig;
  final GetLocalAssistantAvailabilityUseCase _getLocalAvailability;
  final GetRemoteAssistantAvailabilityUseCase _getRemoteAvailability;
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

    final remote = await _getRemoteAvailability();
    final local = await _getLocalAvailability();
    if (emit.isDone || revision != _loadRevision) return;
    emit(
      SettingLoadedState(
        isLanguageSelectorEnabled: isLanguageSelectorEnabled,
        isDevMenuEnabled: _buildConfig.buildEnvironment.isDevMenuEnabled,
        isRemoteAssistantAvailable: remote.isRight && remote.right.isAvailable,
        isLocalAssistantAvailable:
            remote.isRight &&
            !remote.right.isFeatureEnabled &&
            local.isRight &&
            local.right.isAvailable,
      ),
    );
  }
}
