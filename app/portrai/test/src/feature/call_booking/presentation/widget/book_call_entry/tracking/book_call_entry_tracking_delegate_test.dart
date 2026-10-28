import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      Tracking(
        name: 'fallback',
        action: const ClickAction(label: 'fallback'),
      ),
    );
  });

  group('BookCallEntryTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late BookCallEntryTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = BookCallEntryTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send the book call click with its topic', () {
      delegate.trackBookCallClick(
        label: 'service_book_call_button',
        topic: 'App Development',
      );

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;
      expect(tracking.name, 'book_call');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'service_book_call_button');
      expect(tracking.parameters['value'], 'App Development');
    });
  });
}
