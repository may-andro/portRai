import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/connectivity/domain/_domain.dart';
import 'package:portrai/src/feature/connectivity/presentation/bloc/connectivity_event.dart';
import 'package:portrai/src/feature/connectivity/presentation/bloc/connectivity_state.dart';

@register
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc({
    required this._checkInternetConnectionUseCase,
    required this._watchInternetConnectionUseCase,
  }) : super(const ConnectivityInitialState()) {
    on<StartConnectivityMonitoringEvent>(_onStartMonitoringEventToState);
    on<ConnectivityChangedEvent>(_onConnectivityChangedEventToState);
  }

  final CheckInternetConnectionUseCase _checkInternetConnectionUseCase;
  final WatchInternetConnectionUseCase _watchInternetConnectionUseCase;

  StreamSubscription<Object?>? _subscription;

  Future<void> _onStartMonitoringEventToState(
    StartConnectivityMonitoringEvent event,
    Emitter<ConnectivityState> emit,
  ) async {
    await _subscription?.cancel();

    final initial = await _checkInternetConnectionUseCase();
    // Failing to check is not treated as being offline.
    add(
      ConnectivityChangedEvent(
        isConnected: initial.fold((_) => true, (v) => v),
      ),
    );

    _subscription = _watchInternetConnectionUseCase().listen((result) {
      // A failed update is ignored so the banner keeps its last state.
      if (result.isRight) {
        add(ConnectivityChangedEvent(isConnected: result.right));
      }
    });
  }

  void _onConnectivityChangedEventToState(
    ConnectivityChangedEvent event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(
      event.isConnected
          ? const ConnectivityOnlineState()
          : const ConnectivityOfflineState(),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
