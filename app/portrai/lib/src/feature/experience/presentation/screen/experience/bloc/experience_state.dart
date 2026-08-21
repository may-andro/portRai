import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

@immutable
sealed class ExperienceState extends Equatable {
  const ExperienceState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends ExperienceState {
  const LoadingState();
}

final class ErrorState extends ExperienceState {
  const ErrorState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class LoadedState extends ExperienceState {
  const LoadedState({required this.experience, this.profile});

  final ExperienceEntity experience;
  final ProfileEntity? profile;

  @override
  List<Object?> get props => [experience, profile];
}
