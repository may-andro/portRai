import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('ExperienceListTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ExperienceListTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ExperienceListTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a experience click with the item when an item tap is '
        'tracked', () {
      delegate.trackExperienceClick('id_0');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'experience');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'id_0');
    });
  });
}
