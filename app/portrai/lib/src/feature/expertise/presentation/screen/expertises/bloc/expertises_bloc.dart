import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/expertises_event.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/expertises_state.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class ExpertisesBloc extends Bloc<ExpertisesEvent, ExpertisesState>
    with ScreenTrackingBlocMixin<ExpertisesEvent, ExpertisesState> {
  ExpertisesBloc(this._getAllExpertiseUseCase, this._trackingDelegate)
    : super(const LoadingState()) {
    on<LoadExpertisesEvent>(_mapLoadExpertisesEventToState);
    on<ExpertiseClickEvent>(_mapExpertiseClickEventToState);
    trackScreenViewOn<ScreenVisibleEvent>();
    trackViewEventOn<ViewStateVisibleEvent>((event) => event.trackingId);
  }

  final GetAllExpertiseUseCase _getAllExpertiseUseCase;
  final ExpertisesTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  FutureOr<void> _mapLoadExpertisesEventToState(
    LoadExpertisesEvent event,
    Emitter<ExpertisesState> emit,
  ) async {
    emit(const LoadingState());

    final eitherExpertisesResult = await _getAllExpertiseUseCase();
    eitherExpertisesResult.fold(
      (failure) {
        emit(ErrorState(failure: failure));
      },
      (expertises) {
        emit(LoadedState(expertises: expertises));
      },
    );
  }

  void _mapExpertiseClickEventToState(
    ExpertiseClickEvent event,
    Emitter<ExpertisesState> emit,
  ) => _trackingDelegate.trackExpertiseClick(event.expertiseTitle);
}
