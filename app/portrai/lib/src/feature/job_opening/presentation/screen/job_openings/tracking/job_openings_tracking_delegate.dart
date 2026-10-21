import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('job_openings');
}

@register
class JobOpeningsTrackingDelegate extends ScreenTrackingDelegate {
  JobOpeningsTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackJobOpeningClick() {
    trackEvent(
      Tracking(
        name: 'job_opening',
        action: const ClickAction(label: 'open'),
      ),
    );
  }

  void trackJobSearchToggle({required bool isEnabled}) {
    trackEvent(
      Tracking(
        name: 'job_search',
        action: ClickAction(label: isEnabled ? 'enable' : 'disable'),
      ),
    );
  }

  void trackSignOutClick() {
    trackEvent(
      Tracking(
        name: 'sign_out',
        action: const ClickAction(label: 'submit'),
      ),
    );
  }
}
