import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('AppointmentRequestsTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late AppointmentRequestsTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = AppointmentRequestsTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send an appointment_request click with the decision and the '
        'request ID when an answer is tracked', () {
      delegate.trackDecisionClick(decision: 'accept', requestId: 'request-1');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'appointment_request');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'accept');
      expect(tracking.parameters['value'], 'request-1');
    });
  });
}
