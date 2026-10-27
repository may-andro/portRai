import 'package:tracking/src/model/tracking/tracking.dart';

/// A [Tracking] kept in memory after it was sent.
class SentTracking {
  const SentTracking({
    required this.sequenceNumber,
    required this.sentAt,
    required this.tracking,
  });

  /// Position of the event among every event sent since the app started,
  /// counting from 0. Unique, even for events sent at the same time.
  final int sequenceNumber;

  final DateTime sentAt;
  final Tracking tracking;
}
