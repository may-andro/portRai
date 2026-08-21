import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('project');
}

@register
class ProjectTrackingDelegate extends ScreenTrackingDelegate {
  ProjectTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackLoadingContentView() {
    trackEvent(ViewTracking(label: 'loading_content_view'));
  }

  void trackLoadedContentView() {
    trackEvent(ViewTracking(label: 'loaded_content_view'));
  }

  void trackErrorContentView() {
    trackEvent(ViewTracking(label: 'error_content_view'));
  }

  void trackAvailabilityLinkClick(String availabilityLinkName) {
    trackEvent(
      Tracking(
        name: 'availability_link',
        action: ClickAction(label: availabilityLinkName),
      ),
    );
  }

  void trackTabItemSelection(String headerSectionName) {
    trackEvent(
      Tracking(
        name: 'header_tab',
        action: ClickAction(label: headerSectionName),
      ),
    );
  }

  void trackSectionView(String label) {
    trackEvent(ViewTracking(label: label));
  }
}
