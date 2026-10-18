import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('cv_export');
}

@register
class CvExportTrackingDelegate extends ScreenTrackingDelegate {
  CvExportTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackViewEvent(String label) {
    trackEvent(ViewTracking(label: label));
  }

  void trackTemplateSelection(String templateName) {
    trackEvent(
      Tracking(
        name: 'cv_template',
        action: ClickAction(label: templateName),
      ),
    );
  }

  void trackAccentSelection(String accentName) {
    trackEvent(
      Tracking(
        name: 'cv_accent',
        action: ClickAction(label: accentName),
      ),
    );
  }

  void trackPhotoToggle({required bool isIncluded}) {
    trackEvent(
      Tracking(
        name: 'cv_photo',
        action: ClickAction(label: isIncluded ? 'include' : 'exclude'),
      ),
    );
  }

  void trackSectionToggle(String sectionName) {
    trackEvent(
      Tracking(
        name: 'cv_section',
        action: ClickAction(label: sectionName),
      ),
    );
  }

  void trackDownload(String templateName) {
    trackEvent(
      Tracking(
        name: 'cv_download',
        action: ClickAction(label: templateName),
      ),
    );
  }
}
