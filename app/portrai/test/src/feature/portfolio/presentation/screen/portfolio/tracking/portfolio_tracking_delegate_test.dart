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

    for (final isLocal in [true, false]) {
      test(
        'should send only provider metadata when ${isLocal ? 'local' : 'cloud'} assistant is launched',
        () {
          delegate.trackAssistantLaunch(isLocal: isLocal);
          final tracking =
              verify(
                    () => trackingReporter.sendTrackingEvent(captureAny()),
                  ).captured.single
                  as Tracking;
          expect(tracking.name, 'assistant_launch');
          expect(tracking.parameters['label'], isLocal ? 'local' : 'cloud');
          expect(tracking.parameters.keys, isNot(contains('prompt')));
          expect(tracking.parameters.keys, isNot(contains('response')));
        },
      );
    }

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

    for (final (description, track, name, label)
        in <(String, void Function(), String, String)>[
          (
            'see all',
            () => delegate.trackSeeAllClick('services'),
            'see_all',
            'services',
          ),
          ('setting', () => delegate.trackSettingClick(), 'setting', 'open'),
          (
            'experience',
            () => delegate.trackExperienceClick('experience_1'),
            'experience',
            'experience_1',
          ),
          (
            'expertise',
            () => delegate.trackExpertiseClick('Flutter Development'),
            'expertise',
            'Flutter Development',
          ),
          (
            'service',
            () => delegate.trackServiceClick('App Development'),
            'service',
            'App Development',
          ),
          (
            'project',
            () => delegate.trackProjectClick('port-rai'),
            'project',
            'port-rai',
          ),
          ('profile', () => delegate.trackProfileClick(), 'profile', 'open'),
        ]) {
      test(
        'should send a $name click when the $description tap is tracked',
        () {
          track();

          final tracking =
              verify(
                    () => trackingReporter.sendTrackingEvent(captureAny()),
                  ).captured.single
                  as Tracking;

          expect(tracking.name, name);
          expect(tracking.parameters['action'], 'click');
          expect(tracking.parameters['label'], label);
        },
      );
    }
  });
}
