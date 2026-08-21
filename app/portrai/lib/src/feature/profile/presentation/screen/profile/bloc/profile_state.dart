import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:use_case/use_case.dart';

@immutable
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends ProfileState {
  const LoadingState();
}

final class ErrorState extends ProfileState {
  const ErrorState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class LoadedState extends ProfileState {
  const LoadedState({required this.profile});

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}
