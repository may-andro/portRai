import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('ExpertisesTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ExpertisesTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ExpertisesTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a expertise click with the item when an item tap is '
        'tracked', () {
      delegate.trackExpertiseClick('Flutter Development');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'expertise');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'Flutter Development');
    });
  });
}
