import 'package:equatable/equatable.dart';

sealed class DeveloperMenuState extends Equatable {
  const DeveloperMenuState();

  @override
  List<Object?> get props => [];
}

class DeveloperMenuInitialState extends DeveloperMenuState {
  const DeveloperMenuInitialState();
}

class DeveloperMenuLoadingState extends DeveloperMenuState {
  const DeveloperMenuLoadingState();
}

class DeveloperMenuLoadedState extends DeveloperMenuState {
  const DeveloperMenuLoadedState();

  @override
  List<Object?> get props => [];
}

class DeveloperMenuErrorState extends DeveloperMenuState {
  const DeveloperMenuErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
