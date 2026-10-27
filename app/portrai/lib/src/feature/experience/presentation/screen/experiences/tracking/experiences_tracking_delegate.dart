import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('experiences');
}

@register
class ExperiencesTrackingDelegate extends ScreenTrackingDelegate {
  ExperiencesTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackExperienceClick(String experienceId) {
    trackEvent(
      Tracking(
        name: 'experience',
        action: ClickAction(label: experienceId),
      ),
    );
  }
}
