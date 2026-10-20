import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('sign_in');
}

@register
class SignInTrackingDelegate extends ScreenTrackingDelegate {
  SignInTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackSignInClick() {
    trackEvent(
      Tracking(
        name: 'sign_in',
        action: const ClickAction(label: 'submit'),
      ),
    );
  }
}
