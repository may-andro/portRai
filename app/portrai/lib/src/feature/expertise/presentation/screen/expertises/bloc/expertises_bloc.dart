import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/expertises_event.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/expertises_state.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/tracking/_tracking.dart';
import 'package:portrai/src/feature/profile/profile.dart';

@register
class ExpertisesBloc extends Bloc<ExpertisesEvent, ExpertisesState> {
  ExpertisesBloc(
    this._getAllExpertiseUseCase,
    this._getProfileUseCase,
    this._trackingDelegate,
  ) : super(const LoadingState()) {
    on<LoadExpertisesEvent>(_mapLoadExpertisesEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<ViewStateVisibleEvent>(_mapViewStateVisibleEventToState);
  }

  final GetAllExpertiseUseCase _getAllExpertiseUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final ExpertisesTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadExpertisesEventToState(
    LoadExpertisesEvent event,
    Emitter<ExpertisesState> emit,
  ) async {
    emit(const LoadingState());

    final eitherProfileResult = await _getProfileUseCase();
    final profile = eitherProfileResult.fold<ProfileEntity?>(
      (_) => null,
      (profile) => profile,
    );

    final eitherExpertisesResult = await _getAllExpertiseUseCase();
    eitherExpertisesResult.fold(
      (failure) {
        emit(ErrorState(failure: failure));
      },
      (expertises) {
        emit(LoadedState(expertises: expertises, profile: profile));
      },
    );
  }

  // Tracking Events
  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<ExpertisesState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  FutureOr<void> _mapViewStateVisibleEventToState(
    ViewStateVisibleEvent event,
    Emitter<ExpertisesState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }
}
