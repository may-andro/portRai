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

// Tracking Events
final class ScreenVisibleEvent extends ExperiencesEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends ExperiencesEvent {
  const ViewStateVisibleEvent(this.trackingId);

  factory ViewStateVisibleEvent.loading() {
    return const ViewStateVisibleEvent('loading_content_view');
  }

  factory ViewStateVisibleEvent.success() {
    return const ViewStateVisibleEvent('loaded_content_view');
  }

  factory ViewStateVisibleEvent.error() {
    return const ViewStateVisibleEvent('error_content_view');
  }

  final String trackingId;
}
