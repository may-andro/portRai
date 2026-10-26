import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/connectivity/connectivity.dart';
import 'package:portrai/src/feature/splash/presentation/screen/splash/bloc/splash_event.dart';
import 'package:portrai/src/feature/splash/presentation/screen/splash/bloc/splash_state.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  /// The dependency graph isn't built yet while the splash runs, so
  /// [checkInternetConnectionUseCase] is created by hand rather than injected.
  SplashBloc(
    this._moduleInjectorController,
    this._moduleConfigurators, {
    CheckInternetConnectionUseCase? checkInternetConnectionUseCase,
  }) : _checkInternetConnectionUseCase =
           checkInternetConnectionUseCase ??
           ConnectivityModuleConfigurator.createCheckInternetConnectionUseCase(),
       super(SetUpProgressState.initial()) {
    on<InitEvent>(_onInitEventToState);
    on<RetryClickEvent>(_onInitEventToState);
  }

  final CheckInternetConnectionUseCase _checkInternetConnectionUseCase;

  final ModuleInjectorController _moduleInjectorController;

  final List<ModuleConfigurator> _moduleConfigurators;

  final _receivedSetUpStatus = <InjectionStatus>[];

  FutureOr<void> _onInitEventToState(
    SplashEvent event,
    Emitter<SplashState> emit,
  ) async {
    if (state is SetUpNoInternetState) emit(SetUpProgressState.initial());
    _receivedSetUpStatus.clear();

    Object? setUpError;
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
      onError: (error, stackTrace) => setUpError = error,
    );

    if (setUpError == null) {
      emit(SetUpCompetedState(appServiceLocator.get<DesignSystem>()));
      return;
    }
    // Set up runs offline from cached data, so the internet only matters once
    // set up has failed.
    final isConnectedEither = await _checkInternetConnectionUseCase();
    if (isConnectedEither.isRight && !isConnectedEither.right) {
      emit(const SetUpNoInternetState());
      return;
    }
    emit(SetUpErrorState(_setUpErrorCause(setUpError)));
  }

  Object? _setUpErrorCause(Object? error) {
    if (error is InjectionException) {
      return error.message ?? error.cause ?? error;
    }
    return error;
  }
}
