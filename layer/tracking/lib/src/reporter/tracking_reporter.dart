import 'package:tracking/src/model/model.dart';

abstract interface class TrackingReporter {
  void sendTrackingEvent(Tracking tracking);

  /// The kept events in the order they were sent, oldest first, or `null`
  /// when sent events are not kept.
  List<SentTracking>? get sentTrackingEvents;
}
