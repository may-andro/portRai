import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object?> get props => [];
}

final class LoadServicesEvent extends ServicesEvent {
  const LoadServicesEvent();
}

// Tracking Events
final class ScreenVisibleEvent extends ServicesEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends ServicesEvent {
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
