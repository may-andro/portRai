import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

@immutable
sealed class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object> get props => [];
}

final class LoadingState extends ServicesState {
  const LoadingState();
}

final class LoadedState extends ServicesState {
  const LoadedState(this.service);

  final ServiceEntity service;

  @override
  List<Object> get props => [service];
}
