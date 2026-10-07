import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/tracking/_tracking.dart';
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
    registerFallbackValue(
      Tracking(
        name: 'fallback',
        action: const ViewAction(label: 'fallback'),
      ),
    );
  });

  group('PortfolioTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late PortfolioTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = PortfolioTrackingDelegate(trackingReporter);
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
      expect(tracking.parameters['area'], 'portfolio');
    });

    test(
      'should send a view impression event when trackViewEvent is called',
      () {
        delegate.trackViewEvent('loaded_content_view');

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.parameters['event'], 'view_impression');
        expect(tracking.parameters['label'], 'loaded_content_view');
      },
    );

    test('should send a drawer open event when trackDrawerOpen is called', () {
      delegate.trackDrawerOpen();

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'drawer_menu');
      expect(tracking.parameters['label'], 'open');
    });

    test(
      'should send a drawer item click event when trackDrawerItemSelection is called',
      () {
        delegate.trackDrawerItemSelection('portfolio_services_section');

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.name, 'drawer_menu');
        expect(tracking.parameters['label'], 'portfolio_services_section');
      },
    );

    test(
      'should send a header tab click event when trackTabItemSelection is called',
      () {
        delegate.trackTabItemSelection('portfolio_projects_section');

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.name, 'header_tab');
        expect(tracking.parameters['label'], 'portfolio_projects_section');
      },
    );
  });
}
