import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('job_opening');
}

@register
class JobOpeningTrackingDelegate extends ScreenTrackingDelegate {
  JobOpeningTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackApplyClick(String sourceName) {
    trackEvent(
      Tracking(
        name: 'apply',
        action: ClickAction(label: sourceName),
      ),
    );
  }

  void trackGenerateInsightsClick(String sourceName) {
    trackEvent(
      Tracking(
        name: 'generate_insights',
        action: ClickAction(label: sourceName),
      ),
    );
  }
}
