import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/services_event.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/services_state.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/tracking/_tracking.dart';

@register
class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc(this._trackingDelegate) : super(const LoadingState()) {
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
  }

  final ServicesTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<ServicesState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }
}
