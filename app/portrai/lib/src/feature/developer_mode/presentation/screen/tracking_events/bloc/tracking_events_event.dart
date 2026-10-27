import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TrackingEventsEvent extends Equatable {
  const TrackingEventsEvent();

  @override
  List<Object?> get props => [];
}

class TrackingEventsStartedEvent extends TrackingEventsEvent {
  const TrackingEventsStartedEvent();
}

/// Reloads the events, keeping the search and the filters.
class TrackingEventsRefreshClickEvent extends TrackingEventsEvent {
  const TrackingEventsRefreshClickEvent();
}

class TrackingEventsSearchChangedEvent extends TrackingEventsEvent {
  const TrackingEventsSearchChangedEvent(this.searchQuery);

  final String searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}

/// Adds the event name to the name filter, or removes it when it is there.
class TrackingEventsNameFilterClickEvent extends TrackingEventsEvent {
  const TrackingEventsNameFilterClickEvent(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

/// Shows only the events of [area], or of every area when it is `null`.
class TrackingEventsAreaFilterClickEvent extends TrackingEventsEvent {
  const TrackingEventsAreaFilterClickEvent(this.area);

  final String? area;

  @override
  List<Object?> get props => [area];
}

/// Opens the details of the event with [id], or closes them when they are
/// already open.
class TrackingEventClickEvent extends TrackingEventsEvent {
  const TrackingEventClickEvent(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class TrackingEventsClearFiltersClickEvent extends TrackingEventsEvent {
  const TrackingEventsClearFiltersClickEvent();
}

// Tracking Events
final class ScreenVisibleEvent extends TrackingEventsEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends TrackingEventsEvent {
  const ViewStateVisibleEvent(this.trackingId);

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}
