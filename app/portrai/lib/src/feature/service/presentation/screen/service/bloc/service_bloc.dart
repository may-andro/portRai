import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/service_event.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/service_state.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/tracking/_tracking.dart';

@register
class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  ServiceBloc(this._getProfileUseCase, this._trackingDelegate)
    : super(const LoadingState()) {
    on<LoadProfileEvent>(_mapLoadProfileEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
  }

  final GetProfileUseCase _getProfileUseCase;
  final ServiceTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadProfileEventToState(
    LoadProfileEvent event,
    Emitter<ServiceState> emit,
  ) async {
    final eitherProfileResult = await _getProfileUseCase();
    eitherProfileResult.fold(
      (_) {},
      (profile) => emit(LoadedState(profile: profile)),
    );
  }

  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<ServiceState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }
}
