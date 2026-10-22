import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/services_event.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/services_state.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/tracking/_tracking.dart';

@register
class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc(this._getServicesUseCase, this._trackingDelegate)
    : super(const LoadingState()) {
    on<LoadServicesEvent>(_mapLoadServicesEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<ViewStateVisibleEvent>(_mapViewStateVisibleEventToState);
  }

  final GetServicesUseCase _getServicesUseCase;
  final ServicesTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadServicesEventToState(
    LoadServicesEvent event,
    Emitter<ServicesState> emit,
  ) async {
    emit(const LoadingState());

    final eitherServicesResult = await _getServicesUseCase();
    eitherServicesResult.fold(
      (failure) {
        emit(ErrorState(failure: failure));
      },
      (services) {
        emit(LoadedState(services: services));
      },
    );
  }

  // Tracking Events
  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<ServicesState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  FutureOr<void> _mapViewStateVisibleEventToState(
    ViewStateVisibleEvent event,
    Emitter<ServicesState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }
}
