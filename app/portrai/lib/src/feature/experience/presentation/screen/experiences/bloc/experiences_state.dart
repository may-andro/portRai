import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

@immutable
sealed class ExperiencesState extends Equatable {
  const ExperiencesState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends ExperiencesState {
  const LoadingState();
}

final class ErrorState extends ExperiencesState {
  const ErrorState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class LoadedState extends ExperiencesState {
  const LoadedState({required this.experiences, required this.profile});

  final List<ExperienceEntity> experiences;
  final ProfileEntity? profile;

  @override
  List<Object?> get props => [experiences, profile];
}
