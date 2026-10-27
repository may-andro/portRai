import 'dart:collection';

import 'package:tracking/src/model/model.dart';
import 'package:tracking/src/reporter/tracking_reporter.dart';

/// Keeps the most recent sent events in memory, in the order they were sent,
/// so they can be inspected while debugging.
///
/// Only the last [maxEvents] events are kept; older ones are dropped.
class LocalTrackingReporter implements TrackingReporter {
  LocalTrackingReporter({this.maxEvents = defaultMaxEvents})
    : assert(maxEvents > 0, 'maxEvents must be positive');

  /// Number of events kept when no [maxEvents] is given.
  static const defaultMaxEvents = 200;

  /// Largest number of events kept at a time.
  final int maxEvents;

  final Queue<SentTracking> _sentTrackings = Queue();
  int _nextSequenceNumber = 0;

  @override
  void sendTrackingEvent(Tracking tracking) {
    _sentTrackings.addLast(
      SentTracking(
        sequenceNumber: _nextSequenceNumber++,
        sentAt: DateTime.now(),
        tracking: tracking,
      ),
    );
    while (_sentTrackings.length > maxEvents) {
      _sentTrackings.removeFirst();
    }
  }

  @override
  List<SentTracking>? get sentTrackingEvents =>
      List.unmodifiable(_sentTrackings);
}
