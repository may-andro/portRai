import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/job_openings_card/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('JobOpeningsCardTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late JobOpeningsCardTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = JobOpeningsCardTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a job_openings click with the card when the card tap is '
        'tracked', () {
      delegate.trackJobOpeningsClick('job_openings_card');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'job_openings');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'job_openings_card');
    });
  });
}
