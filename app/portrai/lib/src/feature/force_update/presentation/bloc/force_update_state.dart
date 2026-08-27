import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:use_case/use_case.dart';

@immutable
sealed class ForceUpdateState extends Equatable {
  const ForceUpdateState();

  @override
  List<Object?> get props => [];
}

class ForceUpdateInitialState extends ForceUpdateState {
  const ForceUpdateInitialState();
}

class ForceUpdateNotRequiredState extends ForceUpdateState {
  const ForceUpdateNotRequiredState();
}

class ForceUpdateRequiredState extends ForceUpdateState {
  const ForceUpdateRequiredState();
}

/// Emitted when the user tapped "Update Now" but the store couldn't be
/// opened - the update is still required, so the bottom sheet stays open,
/// but the UI should surface this failure (e.g. via a snackbar).
class ForceUpdateLaunchFailedState extends ForceUpdateState {
  const ForceUpdateLaunchFailedState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
