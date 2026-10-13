import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:use_case/use_case.dart';

@immutable
sealed class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends ServicesState {
  const LoadingState();
}

final class ErrorState extends ServicesState {
  const ErrorState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class LoadedState extends ServicesState {
  const LoadedState({required this.services, required this.profile});

  final List<ServiceEntity> services;
  final ProfileEntity? profile;

  @override
  List<Object?> get props => [services, profile];
}
