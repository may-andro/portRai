import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ExperiencesEvent extends Equatable {
  const ExperiencesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadExperiencesEvent extends ExperiencesEvent {
  const LoadExperiencesEvent();
}

final class ExperienceClickEvent extends ExperiencesEvent {
  const ExperienceClickEvent(this.experienceId);

  final String experienceId;

  @override
  List<Object?> get props => [experienceId];
}

// Tracking Events
final class ScreenVisibleEvent extends ExperiencesEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends ExperiencesEvent {
  const ViewStateVisibleEvent(this.trackingId);

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}
