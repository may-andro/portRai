import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class ScheduleAppointmentEntryTrackingDelegate extends TrackingDelegate {
  ScheduleAppointmentEntryTrackingDelegate(super.trackingReporter);

  /// [topic] is what the appointment is about, such as a service's title, or null.
  void trackScheduleAppointmentClick({required String label, String? topic}) {
    trackEvent(
      Tracking(
        name: 'schedule_appointment',
        action: ClickAction(label: label, value: topic),
      ),
    );
  }
}
