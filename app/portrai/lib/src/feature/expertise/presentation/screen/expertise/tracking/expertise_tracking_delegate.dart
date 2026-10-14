import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('expertise');
}

@register
class ExpertiseTrackingDelegate extends ScreenTrackingDelegate {
  ExpertiseTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackContentView() {
    trackEvent(ViewTracking(label: 'loaded_content_view'));
  }
}
