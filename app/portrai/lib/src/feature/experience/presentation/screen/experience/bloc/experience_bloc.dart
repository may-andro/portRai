import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/experience_event.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/experience_state.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/tracking/_tracking.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/profile.dart';

const _logTag = 'ExperienceBloc';

@register
class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  ExperienceBloc(
    this._getExperienceUseCase,
    this._getProfileUseCase,
    this._openExternalUrlUseCase,
    this._logReporter,
    this._trackingDelegate,
  ) : super(const LoadingState()) {
    on<LoadExperienceEvent>(_mapLoadExperienceEventToState);
    on<OpenExternalUrlEvent>(_mapOpenExternalUrlEventToState);
    on<HeaderTabClickEvent>(_mapHeaderTabClickEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<SectionVisibleEvent>(_mapSectionVisibleEventToState);
    on<ViewStateVisibleEvent>(_mapViewStateVisibleEventToState);
  }

  final GetExperienceUseCase _getExperienceUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final LogReporter _logReporter;
  final ExperienceTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadExperienceEventToState(
    LoadExperienceEvent event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(const LoadingState());

    final eitherProfileResult = await _getProfileUseCase();
    final profile = eitherProfileResult.fold((failure) {
      _logReporter.error(
        tag: _logTag,
        'Failed to load profile: ${failure.cause}',
      );
      return null;
    }, (profile) => profile);

    final eitherExperienceResult = await _getExperienceUseCase(event.id);
    eitherExperienceResult.fold(
      (failure) {
        emit(ErrorState(failure: failure));
      },
      (experience) {
        emit(LoadedState(experience: experience, profile: profile));
      },
    );
  }

  FutureOr<void> _mapOpenExternalUrlEventToState(
    OpenExternalUrlEvent event,
    Emitter<ExperienceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LoadedState) return null;

    final eitherResult = await _openExternalUrlUseCase(
      OpenExternalUrlParam(Uri.parse(event.url)),
    );
    eitherResult.fold(
      (failure) {
        _logReporter.error(
          'Failed to open external URL: ${event.url}',
          error: failure.cause,
          tag: _logTag,
        );
      },
      (success) {
        _trackingDelegate.trackExternalLinkClick(event.label);
      },
    );
  }

  // Tracking Events
  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<ExperienceState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  FutureOr<void> _mapViewStateVisibleEventToState(
    ViewStateVisibleEvent event,
    Emitter<ExperienceState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }

  FutureOr<void> _mapHeaderTabClickEventToState(
    HeaderTabClickEvent event,
    Emitter<ExperienceState> emit,
  ) {
    _trackingDelegate.trackTabItemSelection(event.trackingId);
  }

  FutureOr<void> _mapSectionVisibleEventToState(
    SectionVisibleEvent event,
    Emitter<ExperienceState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }
}
