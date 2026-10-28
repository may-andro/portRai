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

  void trackFilterSelection(String filterName) {
    trackEvent(
      Tracking(
        name: 'filter',
        action: ClickAction(label: filterName),
      ),
    );
  }

  /// [label] is the tapped button, such as `next_week`.
  void trackWeekClick(String label) {
    trackEvent(
      Tracking(
        name: 'week',
        action: ClickAction(label: label),
      ),
    );
  }

  /// [day] is the picked local day; only its date is sent.
  void trackDayClick(DateTime day) {
    trackEvent(
      Tracking(
        name: 'day',
        action: ClickAction(
          label: 'timeline_day',
          value: day.toIso8601String().substring(0, 10),
        ),
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
}
