import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/tracking/_tracking.dart';
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

  group('BookCallTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late BookCallTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = BookCallTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    Tracking captured() =>
        verify(
              () => trackingReporter.sendTrackingEvent(captureAny()),
            ).captured.single
            as Tracking;

    test('should send the day click with the day', () {
      delegate.trackDayClick(label: 'call_day_chip', day: '2026-11-03');

      final tracking = captured();
      expect(tracking.name, 'call_day');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'call_day_chip');
      expect(tracking.parameters['value'], '2026-11-03');
    });

    test('should send the slot click with the slot start', () {
      delegate.trackSlotClick(
        label: 'call_slot_chip',
        slotStart: '2026-11-03T14:00:00.000Z',
      );

      final tracking = captured();
      expect(tracking.name, 'call_slot');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'call_slot_chip');
      expect(tracking.parameters['value'], '2026-11-03T14:00:00.000Z');
    });

    test('should send the privacy policy click', () {
      delegate.trackPrivacyPolicyClick('privacy_policy_link');

      final tracking = captured();
      expect(tracking.name, 'privacy_policy');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'privacy_policy_link');
    });

    test('should send the send click', () {
      delegate.trackSendClick('send_call_request_button');

      final tracking = captured();
      expect(tracking.name, 'send_call_request');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'send_call_request_button');
    });
  });
}
