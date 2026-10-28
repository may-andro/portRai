import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class AppointmentRequestsCardTrackingDelegate extends TrackingDelegate {
  AppointmentRequestsCardTrackingDelegate(super.trackingReporter);

  void trackAppointmentRequestsClick(String label) {
    trackEvent(
      Tracking(
        name: 'appointment_requests',
        action: ClickAction(label: label),
      ),
    );
  }
}
