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

  void trackFilterSelection(String filterName) {
    trackEvent(
      Tracking(
        name: 'filter',
        action: ClickAction(label: filterName),
      ),
    );
  }

  void trackClearFiltersClick() {
    trackEvent(
      Tracking(
        name: 'clear_filters',
        action: const ClickAction(label: 'submit'),
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
