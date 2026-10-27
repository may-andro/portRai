import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ExperienceListEvent extends Equatable {
  const ExperienceListEvent();

  @override
  List<Object?> get props => [];
}

final class ExperienceClickEvent extends ExperienceListEvent {
  const ExperienceClickEvent(this.experienceId);

  final String experienceId;

  @override
  List<Object?> get props => [experienceId];
}
