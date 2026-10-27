import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/presentation/widget/design_system_card/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('DesignSystemCardTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late DesignSystemCardTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = DesignSystemCardTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a theme_gallery click with the card when the card tap is '
        'tracked', () {
      delegate.trackThemeGalleryClick('theme_card');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'theme_gallery');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'theme_card');
    });
  });
}
