import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/tracking/_tracking.dart';
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

  group('ScheduleAppointmentEntryTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ScheduleAppointmentEntryTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ScheduleAppointmentEntryTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send the schedule appointment click with its topic', () {
      delegate.trackScheduleAppointmentClick(
        label: 'service_schedule_appointment_button',
        topic: 'App Development',
      );

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;
      expect(tracking.name, 'schedule_appointment');
      expect(tracking.parameters['action'], 'click');
      expect(
        tracking.parameters['label'],
        'service_schedule_appointment_button',
      );
      expect(tracking.parameters['value'], 'App Development');
    });
  });
}
