import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/experiences_event.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/experiences_state.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class ExperiencesBloc extends Bloc<ExperiencesEvent, ExperiencesState>
    with ScreenTrackingBlocMixin<ExperiencesEvent, ExperiencesState> {
  ExperiencesBloc(this._getExperiencesUseCase, this._trackingDelegate)
    : super(const LoadingState()) {
    on<LoadExperiencesEvent>(_mapLoadExperiencesEventToState);
    on<ExperienceClickEvent>(_mapExperienceClickEventToState);
    trackScreenViewOn<ScreenVisibleEvent>();
    trackViewEventOn<ViewStateVisibleEvent>((event) => event.trackingId);
  }

  final GetExperiencesUseCase _getExperiencesUseCase;
  final ExperiencesTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  FutureOr<void> _mapLoadExperiencesEventToState(
    LoadExperiencesEvent event,
    Emitter<ExperiencesState> emit,
  ) async {
    emit(const LoadingState());

    final eitherExperiencesResult = await _getExperiencesUseCase();
    eitherExperiencesResult.fold(
      (failure) {
        emit(ErrorState(failure: failure));
      },
      (experiences) {
        emit(LoadedState(experiences: experiences));
      },
    );
  }

  void _mapExperienceClickEventToState(
    ExperienceClickEvent event,
    Emitter<ExperiencesState> emit,
  ) => _trackingDelegate.trackExperienceClick(event.experienceId);
}
