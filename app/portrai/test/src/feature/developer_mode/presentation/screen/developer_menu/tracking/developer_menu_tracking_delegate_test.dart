import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('DeveloperMenuTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late DeveloperMenuTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = DeveloperMenuTrackingDelegate(trackingReporter);
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
      expect(tracking.parameters['area'], 'developer_menu');
    });

    test('should send a developer menu entry click with the entry when an '
        'entry tap is tracked', () {
      delegate.trackEntryClick('feature_flags');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'developer_menu_entry');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'feature_flags');
    });
  });
}
