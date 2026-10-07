import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class StartConnectivityMonitoringEvent extends ConnectivityEvent {
  const StartConnectivityMonitoringEvent();
}

class ConnectivityChangedEvent extends ConnectivityEvent {
  const ConnectivityChangedEvent({required this.isConnected});

  final bool isConnected;

  @override
  List<Object> get props => [isConnected];
}
