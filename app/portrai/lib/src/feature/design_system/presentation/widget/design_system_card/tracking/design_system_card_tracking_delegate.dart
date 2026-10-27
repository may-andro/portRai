import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class DesignSystemCardTrackingDelegate extends TrackingDelegate {
  DesignSystemCardTrackingDelegate(super.trackingReporter);

  void trackThemeGalleryClick(String label) {
    trackEvent(
      Tracking(
        name: 'theme_gallery',
        action: ClickAction(label: label),
      ),
    );
  }
}
