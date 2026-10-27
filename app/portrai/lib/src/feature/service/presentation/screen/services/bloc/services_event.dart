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

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}
