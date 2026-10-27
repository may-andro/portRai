import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class ExperienceListTrackingDelegate extends TrackingDelegate {
  ExperienceListTrackingDelegate(super.trackingReporter);

  void trackExperienceClick({
    required String label,
    required String experienceId,
  }) {
    trackEvent(
      Tracking(
        name: 'experience',
        action: ClickAction(label: label, value: experienceId),
      ),
    );
  }
}
