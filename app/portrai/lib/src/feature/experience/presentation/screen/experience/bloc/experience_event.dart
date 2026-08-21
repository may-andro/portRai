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
