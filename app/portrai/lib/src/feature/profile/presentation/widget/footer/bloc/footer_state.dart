import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

sealed class FooterState extends Equatable {
  const FooterState();

  @override
  List<Object> get props => [];
}

final class LoadingState extends FooterState {
  const LoadingState();
}

/// The profile could not be loaded, so there is nothing to show.
final class UnavailableState extends FooterState {
  const UnavailableState();
}

final class LoadedState extends FooterState {
  const LoadedState({required this.profile});

  final ProfileEntity profile;

  @override
  List<Object> get props => [profile];
}
