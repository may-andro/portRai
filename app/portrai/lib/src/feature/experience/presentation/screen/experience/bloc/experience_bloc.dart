import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/experience_event.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/experience_state.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/tracking/_tracking.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';

@register
class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  ExperienceBloc(
    this._getExperienceUseCase,
    this._getExperiencesUseCase,
    this._openExternalUrlUseCase,
    this._trackingDelegate,
  ) : super(const LoadingState()) {
    on<LoadExperienceEvent>(_mapLoadExperienceEventToState);
    on<OpenExternalUrlEvent>(_mapOpenExternalUrlEventToState);
    on<HeaderTabClickEvent>(_mapHeaderTabClickEventToState);
    on<AdjacentExperienceClickEvent>(_mapAdjacentExperienceClickEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<SectionVisibleEvent>(_mapSectionVisibleEventToState);
    on<ViewStateVisibleEvent>(_mapViewStateVisibleEventToState);
  }

  final GetExperienceUseCase _getExperienceUseCase;
  final GetExperiencesUseCase _getExperiencesUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final ExperienceTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadExperienceEventToState(
    LoadExperienceEvent event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(const LoadingState());

    final eitherExperienceResult = await _getExperienceUseCase(event.id);
    if (eitherExperienceResult.isLeft) {
      emit(ErrorState(failure: eitherExperienceResult.left));
      return;
    }
    final experience = eitherExperienceResult.right;

    final eitherExperiencesResult = await _getExperiencesUseCase();
    final experiencesNewestFirst = eitherExperiencesResult.fold(
      (_) => <ExperienceEntity>[],
      (experiences) => [...experiences]
        ..sort((first, second) => second.startDate.compareTo(first.startDate)),
    );
    final experienceIndex = experiencesNewestFirst.indexWhere(
      (candidate) => candidate.id == experience.id,
    );
    final hasNewerExperience = experienceIndex > 0;
    final hasOlderExperience =
        experienceIndex >= 0 &&
        experienceIndex < experiencesNewestFirst.length - 1;
    emit(
      LoadedState(
        experience: experience,
        newerExperience: hasNewerExperience
            ? experiencesNewestFirst[experienceIndex - 1]
            : null,
        olderExperience: hasOlderExperience
            ? experiencesNewestFirst[experienceIndex + 1]
            : null,
      ),
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
    if (eitherResult.isRight) {
      _trackingDelegate.trackExternalLinkClick(event.label);
    }
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

  FutureOr<void> _mapAdjacentExperienceClickEventToState(
    AdjacentExperienceClickEvent event,
    Emitter<ExperienceState> emit,
  ) {
    _trackingDelegate.trackAdjacentExperienceClick(event.experienceId);
  }

  FutureOr<void> _mapSectionVisibleEventToState(
    SectionVisibleEvent event,
    Emitter<ExperienceState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }
}
