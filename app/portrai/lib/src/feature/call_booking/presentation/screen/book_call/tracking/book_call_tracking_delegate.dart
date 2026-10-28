import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('book_call');
}

@register
class BookCallTrackingDelegate extends ScreenTrackingDelegate {
  BookCallTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  /// [day] is the local date, such as `2026-11-03`.
  void trackDayClick({required String label, required String day}) {
    trackEvent(
      Tracking(
        name: 'call_day',
        action: ClickAction(label: label, value: day),
      ),
    );
  }

  /// [slotStart] is the slot's start in UTC, as an ISO 8601 string.
  void trackSlotClick({required String label, required String slotStart}) {
    trackEvent(
      Tracking(
        name: 'call_slot',
        action: ClickAction(label: label, value: slotStart),
      ),
    );
  }

  void trackPrivacyPolicyClick(String label) {
    trackEvent(
      Tracking(
        name: 'privacy_policy',
        action: ClickAction(label: label),
      ),
    );
  }

  void trackSendClick(String label) {
    trackEvent(
      Tracking(
        name: 'send_call_request',
        action: ClickAction(label: label),
      ),
    );
  }
}
