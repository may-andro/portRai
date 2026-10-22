import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/services_event.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/services_state.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class ServicesBloc extends Bloc<ServicesEvent, ServicesState>
    with ScreenTrackingBlocMixin<ServicesEvent, ServicesState> {
  ServicesBloc(this._getServicesUseCase, this._trackingDelegate)
    : super(const LoadingState()) {
    on<LoadServicesEvent>(_mapLoadServicesEventToState);
    trackScreenViewOn<ScreenVisibleEvent>();
    trackViewEventOn<ViewStateVisibleEvent>((event) => event.trackingId);
  }

  final GetServicesUseCase _getServicesUseCase;
  final ServicesTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

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
}
