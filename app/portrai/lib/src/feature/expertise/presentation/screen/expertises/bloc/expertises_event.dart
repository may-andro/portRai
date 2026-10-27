import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ExpertisesEvent extends Equatable {
  const ExpertisesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadExpertisesEvent extends ExpertisesEvent {
  const LoadExpertisesEvent();
}

final class ExpertiseClickEvent extends ExpertisesEvent {
  const ExpertiseClickEvent(this.expertiseTitle);

  final String expertiseTitle;

  @override
  List<Object?> get props => [expertiseTitle];
}

// Tracking Events
final class ScreenVisibleEvent extends ExpertisesEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends ExpertisesEvent {
  const ViewStateVisibleEvent(this.trackingId);

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}
