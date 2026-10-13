import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/profile/profile.dart';

@immutable
sealed class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object> get props => [];
}

final class LoadingState extends ServiceState {
  const LoadingState();
}

final class LoadedState extends ServiceState {
  const LoadedState({required this.profile});

  final ProfileEntity profile;

  @override
  List<Object> get props => [profile];
}
