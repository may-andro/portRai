import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

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
  const LoadedState(this.service);

  final ServiceEntity service;

  @override
  List<Object> get props => [service];
}
