import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('feature_flag');
}

@register
class FeatureFlagTrackingDelegate extends ScreenTrackingDelegate {
  FeatureFlagTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackViewEvent(String label) {
    trackEvent(ViewTracking(label: label));
  }
}
