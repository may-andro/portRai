import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/expertise_event.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/expertise_state.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/tracking/_tracking.dart';
import 'package:portrai/src/feature/profile/profile.dart';

@register
class ExpertiseBloc extends Bloc<ExpertiseEvent, ExpertiseState> {
  ExpertiseBloc(this._getProfileUseCase, this._trackingDelegate)
    : super(const ExpertiseState()) {
    on<LoadExpertiseEvent>(_mapLoadExpertiseEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<ContentVisibleEvent>(_mapContentVisibleEventToState);
  }

  final GetProfileUseCase _getProfileUseCase;
  final ExpertiseTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadExpertiseEventToState(
    LoadExpertiseEvent event,
    Emitter<ExpertiseState> emit,
  ) async {
    final eitherProfileResult = await _getProfileUseCase();
    final profile = eitherProfileResult.fold<ProfileEntity?>(
      (_) => null,
      (profile) => profile,
    );
    emit(ExpertiseState(profile: profile));
  }

  // Tracking Events
  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<ExpertiseState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  FutureOr<void> _mapContentVisibleEventToState(
    ContentVisibleEvent event,
    Emitter<ExpertiseState> emit,
  ) {
    _trackingDelegate.trackContentView();
  }
}
