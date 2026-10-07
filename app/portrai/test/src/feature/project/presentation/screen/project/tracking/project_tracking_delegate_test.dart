import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/tracking/_tracking.dart';
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

  group('ProjectTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ProjectTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ProjectTrackingDelegate(trackingReporter);
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
      expect(tracking.parameters['area'], 'project');
    });

    test(
      'should send a view impression when trackLoadedContentView is called',
      () {
        delegate.trackLoadedContentView();

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.parameters['event'], 'view_impression');
        expect(tracking.parameters['label'], 'loaded_content_view');
      },
    );

    test(
      'should send a click event when trackAvailabilityLinkClick is called',
      () {
        delegate.trackAvailabilityLinkClick('GitHub');

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.name, 'availability_link');
        expect(tracking.parameters['label'], 'GitHub');
      },
    );

    test('should send a click event when trackTabItemSelection is called', () {
      delegate.trackTabItemSelection('project_overview_section');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'header_tab');
      expect(tracking.parameters['label'], 'project_overview_section');
    });
  });
}
