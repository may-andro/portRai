import 'package:design_system/design_system.dart';
import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('design_system_gallery');
}

@register
class DesignSystemGalleryTrackingDelegate extends ScreenTrackingDelegate {
  DesignSystemGalleryTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackPreview(DesignSystem designSystem) {
    trackEvent(
      Tracking(
        name: 'theme_preview',
        action: ClickAction(label: designSystem.name),
      ),
    );
  }

  void trackApply(DesignSystem designSystem) {
    trackEvent(
      Tracking(
        name: 'theme_apply',
        action: ClickAction(label: designSystem.name),
      ),
    );
  }
}
