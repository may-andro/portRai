import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';
import 'package:use_case/use_case.dart';

sealed class TrackingEventsState extends Equatable {
  const TrackingEventsState();

  @override
  List<Object?> get props => [];
}

class TrackingEventsLoadingState extends TrackingEventsState {
  const TrackingEventsLoadingState();
}

class TrackingEventsLoadedState extends TrackingEventsState {
  const TrackingEventsLoadedState(
    this.trackingEvents, {
    this.searchQuery = '',
    this.nameFilters = const {},
    this.areaFilter,
    this.selectedTrackingEventId,
  });

  /// The events sent in this session, in the order they were sent.
  final List<TrackingEventEntity> trackingEvents;

  final String searchQuery;

  /// Event names to show; every name when empty.
  final Set<String> nameFilters;

  /// Area to show; every area when `null`.
  final String? areaFilter;

  /// ID of the event whose details are open; none when `null`.
  final String? selectedTrackingEventId;

  /// The event whose details are open, while it is among the shown events.
  TrackingEventEntity? get selectedTrackingEvent {
    final selectedTrackingEventId = this.selectedTrackingEventId;
    if (selectedTrackingEventId == null) return null;
    return visibleTrackingEvents
        .where((trackingEvent) => trackingEvent.id == selectedTrackingEventId)
        .firstOrNull;
  }

  bool get isNarrowed =>
      searchQuery.trim().isNotEmpty ||
      nameFilters.isNotEmpty ||
      areaFilter != null;

  /// How many events have each name, by most frequent first.
  Map<String, int> get nameCounts =>
      _countsOf(trackingEvents.map((trackingEvent) => trackingEvent.name));

  /// How many events were sent from each area, by most frequent first.
  Map<String, int> get areaCounts =>
      _countsOf(trackingEvents.map((trackingEvent) => trackingEvent.area));

  /// [trackingEvents] that match every word of [searchQuery], one of the
  /// [nameFilters] and the [areaFilter].
  List<TrackingEventEntity> get visibleTrackingEvents {
    if (!isNarrowed) return trackingEvents;

    final searchWords = searchQuery
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    return trackingEvents.where((trackingEvent) {
      final searchableText = [
        ...trackingEvent.parameters.keys,
        ...trackingEvent.parameters.values,
      ].join(' ').toLowerCase();
      return searchWords.every(searchableText.contains) &&
          (nameFilters.isEmpty || nameFilters.contains(trackingEvent.name)) &&
          (areaFilter == null || areaFilter == trackingEvent.area);
    }).toList();
  }

  TrackingEventsLoadedState copyWith({
    List<TrackingEventEntity>? trackingEvents,
    String? searchQuery,
    Set<String>? nameFilters,
    String? areaFilter,
    bool clearAreaFilter = false,
    String? selectedTrackingEventId,
    bool clearSelectedTrackingEvent = false,
  }) {
    return TrackingEventsLoadedState(
      trackingEvents ?? this.trackingEvents,
      searchQuery: searchQuery ?? this.searchQuery,
      nameFilters: nameFilters ?? this.nameFilters,
      areaFilter: clearAreaFilter ? null : areaFilter ?? this.areaFilter,
      selectedTrackingEventId: clearSelectedTrackingEvent
          ? null
          : selectedTrackingEventId ?? this.selectedTrackingEventId,
    );
  }

  @override
  List<Object?> get props => [
    trackingEvents,
    searchQuery,
    nameFilters,
    areaFilter,
    selectedTrackingEventId,
  ];
}

class TrackingEventsErrorState extends TrackingEventsState {
  const TrackingEventsErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

Map<String, int> _countsOf(Iterable<String> keys) {
  final counts = <String, int>{};
  for (final key in keys) {
    counts[key] = (counts[key] ?? 0) + 1;
  }
  final sortedEntries = counts.entries.toList()
    ..sort((first, second) => second.value.compareTo(first.value));
  return Map.fromEntries(sortedEntries);
}
