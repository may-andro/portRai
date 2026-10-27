import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('JobOpeningsTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late JobOpeningsTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = JobOpeningsTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a job opening click with the card and the opening when '
        'an opening tap is tracked', () {
      delegate.trackJobOpeningClick(
        label: 'job_opening_card',
        jobOpeningId: 'job-1',
      );

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'job_opening');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'job_opening_card');
      expect(tracking.parameters['value'], 'job-1');
    });
  });
}
