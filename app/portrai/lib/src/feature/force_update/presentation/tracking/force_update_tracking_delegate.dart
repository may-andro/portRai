import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('force_update');
}

@register
class ForceUpdateTrackingDelegate extends ScreenTrackingDelegate {
  ForceUpdateTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackUpdateNowClick() {
    trackEvent(ClickTracking(label: 'update_now'));
  }
}
