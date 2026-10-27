import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('ExperiencesTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ExperiencesTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ExperiencesTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a experience click with the item when an item tap is '
        'tracked', () {
      delegate.trackExperienceClick('experience_1');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'experience');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'experience_1');
    });
  });
}
