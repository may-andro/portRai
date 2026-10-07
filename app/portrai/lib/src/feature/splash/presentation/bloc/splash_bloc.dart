import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/connectivity/connectivity.dart';
import 'package:portrai/src/feature/splash/presentation/bloc/splash_event.dart';
import 'package:portrai/src/feature/splash/presentation/bloc/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  /// The dependency graph isn't built yet while the splash runs, so
  /// [connectivityRepository] is created by hand rather than injected.
  SplashBloc(
    this._moduleInjectorController,
    this._moduleConfigurators, {
    ConnectivityRepository? connectivityRepository,
  }) : _connectivityRepository =
           connectivityRepository ??
           ConnectivityPlusRepositoryImpl.standalone(),
       super(SetUpProgressState.initial()) {
    on<InitEvent>(_onInitEventToState);
    on<RetryClickEvent>(_onInitEventToState);
  }

  final ConnectivityRepository _connectivityRepository;

  final ModuleInjectorController _moduleInjectorController;

  final List<ModuleConfigurator> _moduleConfigurators;

  final _receivedSetUpStatus = <InjectionStatus>[];

  bool _errorDuringDI = false;

  FutureOr<void> _onInitEventToState(
    SplashEvent event,
    Emitter<SplashState> emit,
  ) async {
    if (state is SetUpNoInternetState) emit(SetUpProgressState.initial());
    if (!await _connectivityRepository.isConnected()) {
      emit(const SetUpNoInternetState());
      return;
    }

    await emit.onEach<InjectionStatus>(
      _moduleInjectorController.setUpDIGraph(
        configurators: _moduleConfigurators,
      ),
      onData: (setUpStatus) {
        _receivedSetUpStatus.add(setUpStatus);
        final progress =
            _receivedSetUpStatus.length / InjectionStatus.values.length;
        emit(
          SetUpProgressState(List.unmodifiable(_receivedSetUpStatus), progress),
        );
      },
      onError: (error, stackTrace) {
        _errorDuringDI = true;
        if (error is InjectionException) {
          emit(SetUpErrorState(error.message ?? error.cause ?? error));
          return;
        }
        emit(SetUpErrorState(error));
      },
    );

    if (!_errorDuringDI) {
      emit(const SetUpCompetedState(DesignSystem.hogmanay));
    }
  }
}
