import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('profile');
}

@register
class ProfileTrackingDelegate extends ScreenTrackingDelegate {
  ProfileTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackViewEvent(String label) {
    trackEvent(ViewTracking(label: label));
  }

  void trackExternalLinkClick(String url) {
    trackEvent(
      Tracking(
        name: 'external_link',
        action: ClickAction(label: url),
      ),
    );
  }
}
