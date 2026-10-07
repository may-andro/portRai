import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

class ConnectivityInitialState extends ConnectivityState {
  const ConnectivityInitialState();
}

class ConnectivityOnlineState extends ConnectivityState {
  const ConnectivityOnlineState();
}

class ConnectivityOfflineState extends ConnectivityState {
  const ConnectivityOfflineState();
}
