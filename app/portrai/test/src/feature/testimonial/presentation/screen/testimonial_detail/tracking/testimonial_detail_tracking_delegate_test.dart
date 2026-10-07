import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
    registerFallbackValue(
      Tracking(
        name: 'fallback',
        action: const ClickAction(label: 'fallback'),
      ),
    );
  });

  group('TestimonialDetailTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late TestimonialDetailTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = TestimonialDetailTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a screen view event when trackScreenView is called', () {
      delegate.trackScreenView();

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.parameters['event'], 'screen_view');
      expect(tracking.parameters['area'], 'testimonial_detail');
    });
  });
}
