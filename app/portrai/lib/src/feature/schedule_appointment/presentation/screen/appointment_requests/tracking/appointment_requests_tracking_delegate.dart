import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('appointment_requests');
}

@register
class AppointmentRequestsTrackingDelegate extends ScreenTrackingDelegate {
  AppointmentRequestsTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  /// [decision] is `accept` or `decline`.
  void trackDecisionClick({
    required String decision,
    required String requestId,
  }) {
    trackEvent(
      Tracking(
        name: 'appointment_request',
        action: ClickAction(label: decision, value: requestId),
      ),
    );
  }
}
