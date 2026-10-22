import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/expertise_event.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/expertise_state.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class ExpertiseBloc extends Bloc<ExpertiseEvent, ExpertiseState>
    with ScreenTrackingBlocMixin<ExpertiseEvent, ExpertiseState> {
  ExpertiseBloc(this._trackingDelegate) : super(const ExpertiseState()) {
    trackScreenViewOn<ScreenVisibleEvent>();
    on<ContentVisibleEvent>(_mapContentVisibleEventToState);
  }

  final ExpertiseTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  // Tracking Events

  FutureOr<void> _mapContentVisibleEventToState(
    ContentVisibleEvent event,
    Emitter<ExpertiseState> emit,
  ) {
    _trackingDelegate.trackContentView();
  }
}
