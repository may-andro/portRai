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

// Tracking Events
final class ScreenVisibleEvent extends ExpertisesEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends ExpertisesEvent {
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
