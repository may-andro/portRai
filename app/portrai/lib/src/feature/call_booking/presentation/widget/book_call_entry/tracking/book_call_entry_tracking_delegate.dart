import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class BookCallEntryTrackingDelegate extends TrackingDelegate {
  BookCallEntryTrackingDelegate(super.trackingReporter);

  /// [topic] is what the call is about, such as a service's title, or null.
  void trackBookCallClick({required String label, String? topic}) {
    trackEvent(
      Tracking(
        name: 'book_call',
        action: ClickAction(label: label, value: topic),
      ),
    );
  }
}
