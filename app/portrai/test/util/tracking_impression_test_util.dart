import 'package:tracking/tracking.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Resets `TrackingImpressionDetectorWidget`'s process-wide de-dupe set and
/// makes `VisibilityDetector` report visibility synchronously.
///
/// Call this in `setUp()` for any widget test that pumps a
/// `TrackingImpressionDetectorWidget` (directly or nested), so tracking
/// impressions fire deterministically and don't leak state between tests
/// that pump the same widget.
void resetTrackingImpressions() {
  triggeredImpressions.clear();
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
}
