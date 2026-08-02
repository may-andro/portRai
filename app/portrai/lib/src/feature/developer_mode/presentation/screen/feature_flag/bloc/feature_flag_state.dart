import 'package:equatable/equatable.dart';

sealed class FeatureFlagState extends Equatable {
  const FeatureFlagState();

  @override
  List<Object?> get props => [];
}

class FeatureFlagInitialState extends FeatureFlagState {
  const FeatureFlagInitialState();
}

class FeatureFlagLoadingState extends FeatureFlagState {
  const FeatureFlagLoadingState();
}

class FeatureFlagLoadedState extends FeatureFlagState {
  const FeatureFlagLoadedState();

  @override
  List<Object?> get props => [];
}

class FeatureFlagErrorState extends FeatureFlagState {
  const FeatureFlagErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
