import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

@immutable
sealed class ExpertisesState extends Equatable {
  const ExpertisesState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends ExpertisesState {
  const LoadingState();
}

final class ErrorState extends ExpertisesState {
  const ErrorState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class LoadedState extends ExpertisesState {
  const LoadedState({required this.expertises, required this.profile});

  final List<ExpertiseEntity> expertises;
  final ProfileEntity? profile;

  @override
  List<Object?> get props => [expertises, profile];
}
