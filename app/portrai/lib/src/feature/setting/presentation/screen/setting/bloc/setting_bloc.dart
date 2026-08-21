import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_event.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_state.dart';

@register
class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc(this._isFeatureEnabledUseCase) 
      : super(const SettingInitialState()) {
    on<LoadSettingsEvent>(_mapLoadSettingsEventToState);
  }

  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;

  Future<void> _mapLoadSettingsEventToState(
    LoadSettingsEvent event,
    Emitter<SettingState> emit,
  ) async {
    emit(const SettingLoadingState());

    final languageSelectorResult = await _isFeatureEnabledUseCase(
      AppFeatureFlag.languageSelector,
    );

    final isLanguageSelectorEnabled = languageSelectorResult.fold(
      (_) => AppFeatureFlag.languageSelector.defaultValue,
      (isEnabled) => isEnabled,
    );

    emit(SettingLoadedState(
      isLanguageSelectorEnabled: isLanguageSelectorEnabled,
    ));
  }
}
