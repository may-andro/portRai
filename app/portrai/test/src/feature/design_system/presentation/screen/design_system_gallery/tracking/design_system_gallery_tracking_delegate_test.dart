import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('DesignSystemGalleryTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late DesignSystemGalleryTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = DesignSystemGalleryTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    Tracking capturedTracking() =>
        verify(
              () => trackingReporter.sendTrackingEvent(captureAny()),
            ).captured.single
            as Tracking;

    test('should send a screen view in the gallery area when the screen is '
        'shown', () {
      delegate.trackScreenView();

      final tracking = capturedTracking();
      expect(tracking.parameters['event'], 'screen_view');
      expect(tracking.parameters['area'], 'design_system_gallery');
    });

    test('should send a click labelled with the design system when a theme '
        'is previewed', () {
      delegate.trackPreview(DesignSystem.holi);

      final tracking = capturedTracking();
      expect(tracking.name, 'theme_preview');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'holi');
    });

    test('should send a click labelled with the design system when a theme '
        'is applied', () {
      delegate.trackApply(DesignSystem.sakura);

      final tracking = capturedTracking();
      expect(tracking.name, 'theme_apply');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'sakura');
    });
  });
}
