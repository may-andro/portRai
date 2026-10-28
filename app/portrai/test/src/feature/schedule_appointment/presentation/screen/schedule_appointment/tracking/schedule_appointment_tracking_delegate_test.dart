import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/tracking/_tracking.dart';
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

  group('ScheduleAppointmentTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ScheduleAppointmentTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ScheduleAppointmentTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    Tracking captured() =>
        verify(
              () => trackingReporter.sendTrackingEvent(captureAny()),
            ).captured.single
            as Tracking;

    test('should send the day click with the day', () {
      delegate.trackDayClick(label: 'appointment_day_chip', day: '2026-11-03');

      final tracking = captured();
      expect(tracking.name, 'appointment_day');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'appointment_day_chip');
      expect(tracking.parameters['value'], '2026-11-03');
    });

    test('should send the slot click with the slot start', () {
      delegate.trackSlotClick(
        label: 'appointment_slot_chip',
        slotStart: '2026-11-03T14:00:00.000Z',
      );

      final tracking = captured();
      expect(tracking.name, 'appointment_slot');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'appointment_slot_chip');
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
      delegate.trackSendClick('send_appointment_request_button');

      final tracking = captured();
      expect(tracking.name, 'send_appointment_request');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'send_appointment_request_button');
    });
  });
}
