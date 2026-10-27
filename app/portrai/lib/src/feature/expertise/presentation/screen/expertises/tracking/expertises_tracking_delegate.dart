import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('expertises');
}

@register
class ExpertisesTrackingDelegate extends ScreenTrackingDelegate {
  ExpertisesTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackExpertiseClick(String expertiseTitle) {
    trackEvent(
      Tracking(
        name: 'expertise',
        action: ClickAction(label: expertiseTitle),
      ),
    );
  }
}
