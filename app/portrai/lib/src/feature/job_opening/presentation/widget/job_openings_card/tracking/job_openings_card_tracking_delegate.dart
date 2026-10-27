import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class JobOpeningsCardTrackingDelegate extends TrackingDelegate {
  JobOpeningsCardTrackingDelegate(super.trackingReporter);

  void trackJobOpeningsClick(String label) {
    trackEvent(
      Tracking(
        name: 'job_openings',
        action: ClickAction(label: label),
      ),
    );
  }
}
