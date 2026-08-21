import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/locale_selection_event.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/locale_selection_state.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/locale_selection_state_extension.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/locale_selection_state_factory.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/tracking/_tracking.dart';
import 'package:portrai/src/feature/profile/profile.dart';

const _logTag = 'LocaleSelectionBloc';

@register
class LocaleSelectionBloc
    extends Bloc<LocaleSelectionEvent, LocaleSelectionState> {
  LocaleSelectionBloc(
    this._getLocaleUseCase,
    this._updateLocaleUseCase,
    this._getProfileUseCase,
    this._logReporter,
    this._trackingDelegate,
  ) : super(LocaleSelectionStateFactory.loading()) {
    on<LoadLocaleEvent>(_mapLoadLocaleEventToState);
    on<UpdateLocaleEvent>(_mapUpdateLocaleEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<ViewStateVisibleEvent>(_mapViewStateVisibleEventToState);
  }

  final GetLocaleUseCase _getLocaleUseCase;
  final UpdateLocaleUseCase _updateLocaleUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final LogReporter _logReporter;
  final LocaleSelectionTrackingDelegate _trackingDelegate;

  Future<void> _mapLoadLocaleEventToState(
    LoadLocaleEvent event,
    Emitter<LocaleSelectionState> emit,
  ) async {
    emit(LocaleSelectionStateFactory.loading());

    final eitherProfileResult = await _getProfileUseCase();
    final profile = eitherProfileResult.fold((failure) {
      _logReporter.error(
        tag: _logTag,
        'Failed to load profile: ${failure.cause}',
      );
      return null;
    }, (profile) => profile);

    final localeEither = await _getLocaleUseCase();
    localeEither.fold(
      (failure) {
        return emit(LocaleSelectionStateFactory.loadError(failure: failure));
      },
      (appLocale) {
        return emit(
          LocaleSelectionStateFactory.loaded(
            supportedLocales: AppLocalizations.supportedLocales,
            appLocale: appLocale,
            profile: profile,
          ),
        );
      },
    );
  }

  Future<void> _mapUpdateLocaleEventToState(
    UpdateLocaleEvent event,
    Emitter<LocaleSelectionState> emit,
  ) async {
    final currentState = state.dataState;
    if (currentState == null) return;

    final targetLocale = event.updatedLocale.appLocale;
    _trackingDelegate.trackLocaleSelectionClick(targetLocale.languageCode);

    // Emit updating state to show progress
    emit(
      LocaleSelectionStateFactory.updating(
        supportedLocales: currentState.supportedLocales,
        appLocale: currentState.appLocale,
        targetLocale: targetLocale,
      ),
    );

    final eitherResult = await _updateLocaleUseCase(targetLocale);

    eitherResult.fold(
      (failure) {
        emit(
          LocaleSelectionStateFactory.updateFailure(
            supportedLocales: currentState.supportedLocales,
            appLocale: currentState.appLocale,
            failure: failure,
            targetLocale: targetLocale,
          ),
        );
      },
      (_) {
        _trackingDelegate.trackLanguageUpdate(
          previousLanguage: currentState.appLocale.languageCode,
          newLanguage: targetLocale.languageCode,
        );
        emit(
          LocaleSelectionStateFactory.loaded(
            supportedLocales: currentState.supportedLocales,
            appLocale: targetLocale,
          ),
        );
      },
    );
  }

  // Tracking Events
  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<LocaleSelectionState> emit,
  ) {
    _trackingDelegate.trackScreenView(event.isDialog);
  }

  FutureOr<void> _mapViewStateVisibleEventToState(
    ViewStateVisibleEvent event,
    Emitter<LocaleSelectionState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }
}
