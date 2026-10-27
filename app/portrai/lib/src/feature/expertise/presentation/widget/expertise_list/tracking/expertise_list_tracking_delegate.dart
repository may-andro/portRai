import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class ExpertiseListTrackingDelegate extends TrackingDelegate {
  ExpertiseListTrackingDelegate(super.trackingReporter);

  void trackExpertiseClick({
    required String label,
    required String expertiseTitle,
  }) {
    trackEvent(
      Tracking(
        name: 'expertise',
        action: ClickAction(label: label, value: expertiseTitle),
      ),
    );
  }
}
