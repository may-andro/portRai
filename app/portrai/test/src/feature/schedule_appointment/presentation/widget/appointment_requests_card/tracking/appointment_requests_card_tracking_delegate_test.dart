import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/appointment_requests_card/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('AppointmentRequestsCardTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late AppointmentRequestsCardTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = AppointmentRequestsCardTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send an appointment_requests click with the card when the '
        'card tap is tracked', () {
      delegate.trackAppointmentRequestsClick('appointment_requests_card');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'appointment_requests');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'appointment_requests_card');
    });
  });
}
