import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class ServiceListTrackingDelegate extends TrackingDelegate {
  ServiceListTrackingDelegate(super.trackingReporter);

  void trackServiceClick(String serviceTitle) {
    trackEvent(
      Tracking(
        name: 'service',
        action: ClickAction(label: serviceTitle),
      ),
    );
  }
}
