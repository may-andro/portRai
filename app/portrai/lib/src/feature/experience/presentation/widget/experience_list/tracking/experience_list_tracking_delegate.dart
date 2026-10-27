import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class ExperienceListTrackingDelegate extends TrackingDelegate {
  ExperienceListTrackingDelegate(super.trackingReporter);

  void trackExperienceClick(String experienceId) {
    trackEvent(
      Tracking(
        name: 'experience',
        action: ClickAction(label: experienceId),
      ),
    );
  }
}
