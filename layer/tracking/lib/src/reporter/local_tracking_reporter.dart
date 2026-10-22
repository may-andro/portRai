import 'package:tracking/src/model/model.dart';
import 'package:tracking/src/reporter/tracking_reporter.dart';

/// Keeps the most recent sent events in memory so they can be inspected while
/// debugging.
///
/// Only the last [maxEvents] events are kept; older ones are dropped.
class LocalTrackingReporter implements TrackingReporter {
  LocalTrackingReporter({this.maxEvents = defaultMaxEvents})
    : assert(maxEvents > 0, 'maxEvents must be positive');

  /// Number of events kept when no [maxEvents] is given.
  static const defaultMaxEvents = 200;

  /// Largest number of events kept at a time.
  final int maxEvents;

  // Insertion ordered, so the first key is the oldest event.
  final Map<DateTime, Tracking> _trackingMap = {};

  @override
  void sendTrackingEvent(Tracking tracking) {
    _trackingMap[DateTime.now()] = tracking;
    while (_trackingMap.length > maxEvents) {
      _trackingMap.remove(_trackingMap.keys.first);
    }
  }

  @override
  Map<DateTime, Tracking>? get sentTrackingEvents =>
      Map.unmodifiable(_trackingMap);
}
