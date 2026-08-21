import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class FooterTrackingDelegate extends TrackingDelegate {
  FooterTrackingDelegate(super.trackingReporter);

  void trackExternalLinkClick(String url) {
    trackEvent(
      Tracking(
        name: 'external_link',
        action: ClickAction(label: url),
      ),
    );
  }

  void trackEmailClick(String url) {
    trackEvent(
      Tracking(
        name: 'email_click',
        action: ClickAction(label: url),
      ),
    );
  }
}
