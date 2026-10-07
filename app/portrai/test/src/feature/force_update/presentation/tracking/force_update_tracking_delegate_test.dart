import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/force_update/presentation/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ClickTracking(label: 'fallback'));
  });

  group('ForceUpdateTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ForceUpdateTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ForceUpdateTrackingDelegate(trackingReporter);
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
      expect(tracking.parameters['area'], 'force_update');
    });

    test('should send a click event when trackUpdateNowClick is called', () {
      delegate.trackUpdateNowClick();

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.parameters['event'], 'click');
      expect(tracking.parameters['label'], 'update_now');
      expect(tracking.parameters['area'], 'force_update');
    });
  });
}
