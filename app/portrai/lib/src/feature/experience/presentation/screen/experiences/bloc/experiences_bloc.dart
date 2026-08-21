import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/experiences_event.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/experiences_state.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/tracking/_tracking.dart';
import 'package:portrai/src/feature/profile/profile.dart';

const _logTag = 'ExperiencesBloc';

@register
class ExperiencesBloc extends Bloc<ExperiencesEvent, ExperiencesState> {
  ExperiencesBloc(
    this._getExperiencesUseCase,
    this._getProfileUseCase,
    this._logReporter,
    this._trackingDelegate,
  ) : super(const LoadingState()) {
    on<LoadExperiencesEvent>(_mapLoadExperiencesEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<ViewStateVisibleEvent>(_mapViewStateVisibleEventToState);
  }

  final GetExperiencesUseCase _getExperiencesUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final LogReporter _logReporter;
  final ExperiencesTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadExperiencesEventToState(
    LoadExperiencesEvent event,
    Emitter<ExperiencesState> emit,
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

    final eitherExperiencesResult = await _getExperiencesUseCase();
    eitherExperiencesResult.fold(
      (failure) {
        emit(ErrorState(failure: failure));
      },
      (experiences) {
        emit(LoadedState(experiences: experiences, profile: profile));
      },
    );
  }

  // Tracking Events
  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<ExperiencesState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  FutureOr<void> _mapViewStateVisibleEventToState(
    ViewStateVisibleEvent event,
    Emitter<ExperiencesState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }
}
