import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/expertise_event.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/expertise_state.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/tracking/_tracking.dart';

@register
class ExpertiseBloc extends Bloc<ExpertiseEvent, ExpertiseState> {
  ExpertiseBloc(this._trackingDelegate) : super(const ExpertiseState()) {
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<ContentVisibleEvent>(_mapContentVisibleEventToState);
  }

  final ExpertiseTrackingDelegate _trackingDelegate;

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
