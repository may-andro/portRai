import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class PersonalSummaryTrackingDelegate extends TrackingDelegate {
  PersonalSummaryTrackingDelegate(super.trackingReporter);

  void trackViewProfileClick(String label) {
    trackEvent(
      Tracking(
        name: 'profile',
        action: ClickAction(label: label),
      ),
    );
  }
}
