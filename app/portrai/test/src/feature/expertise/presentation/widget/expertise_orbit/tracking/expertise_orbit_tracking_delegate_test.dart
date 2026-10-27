import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_orbit/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('ExpertiseOrbitTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ExpertiseOrbitTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ExpertiseOrbitTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test(
      'should send a expertise click with the element and item when an item tap is '
      'tracked',
      () {
        delegate.trackExpertiseClick(
          label: 'expertise_orbit_node',
          expertiseTitle: 'Flutter Development',
        );

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.name, 'expertise');
        expect(tracking.parameters['action'], 'click');
        expect(tracking.parameters['label'], 'expertise_orbit_node');
        expect(tracking.parameters['value'], 'Flutter Development');
      },
    );
  });
}
