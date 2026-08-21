import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

final class OpenExternalUrlEvent extends ProfileEvent {
  const OpenExternalUrlEvent({required this.url, required this.label});

  final String url;
  final String label;

  @override
  List<Object?> get props => [url, label];
}

// Tracking Events
final class ScreenVisibleEvent extends ProfileEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends ProfileEvent {
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
