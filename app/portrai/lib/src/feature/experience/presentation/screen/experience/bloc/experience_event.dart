import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ExperienceEvent extends Equatable {
  const ExperienceEvent();

  @override
  List<Object?> get props => [];
}

final class LoadExperienceEvent extends ExperienceEvent {
  const LoadExperienceEvent(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class OpenExternalUrlEvent extends ExperienceEvent {
  const OpenExternalUrlEvent({required this.url, required this.label});

  final String url;
  final String label;

  @override
  List<Object?> get props => [url, label];
}

final class HeaderTabClickEvent extends ExperienceEvent {
  const HeaderTabClickEvent(this.trackingId);

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}

final class AdjacentExperienceClickEvent extends ExperienceEvent {
  const AdjacentExperienceClickEvent(this.experienceId);

  final String experienceId;

  @override
  List<Object?> get props => [experienceId];
}

// Tracking Events
final class ScreenVisibleEvent extends ExperienceEvent {
  const ScreenVisibleEvent();
}

final class SectionVisibleEvent extends ExperienceEvent {
  const SectionVisibleEvent(this.trackingId);

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}

final class ViewStateVisibleEvent extends ExperienceEvent {
  const ViewStateVisibleEvent(this.trackingId);

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}
