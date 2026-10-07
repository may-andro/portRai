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

    test(
      'should send a view impression event when trackViewEvent is called',
      () {
        delegate.trackViewEvent('developer_menu_loaded_content_view');

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.parameters['event'], 'view_impression');
        expect(
          tracking.parameters['label'],
          'developer_menu_loaded_content_view',
        );
      },
    );
  });
}
