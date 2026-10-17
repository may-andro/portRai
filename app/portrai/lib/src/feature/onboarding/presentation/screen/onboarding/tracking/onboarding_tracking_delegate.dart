import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('onboarding');
}

@register
class OnboardingTrackingDelegate extends ScreenTrackingDelegate {
  OnboardingTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackRoleSelection(String roleName) {
    trackEvent(
      Tracking(
        name: 'selected_role',
        action: ClickAction(label: roleName),
      ),
    );
  }
}
