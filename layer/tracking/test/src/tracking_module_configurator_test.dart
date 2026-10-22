import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking/src/model/model.dart';
import 'package:tracking/src/reporter/reporter.dart';
import 'package:tracking/src/tracking_module_configurator.dart';

import '../_mock/mock_fb_analytics_controller.dart';
import '../_mock/mock_service_locator.dart';

void main() {
  group(TrackingModuleConfigurator, () {
    late MockServiceLocator serviceLocator;

    setUp(() {
      serviceLocator = MockServiceLocator();
      when(
        () => serviceLocator.get<FbAnalyticsController>(),
      ).thenReturn(MockFbAnalyticsController());
    });

    TrackingReporter registeredReporter() {
      final factory =
          verify(
                () => serviceLocator.registerSingleton<TrackingReporter>(
                  captureAny(),
                ),
              ).captured.single
              as TrackingReporter Function();
      return factory();
    }

    test('should keep sent events in memory when running a debug build', () {
      TrackingModuleConfigurator(false).registerDependencies(serviceLocator);
      final reporter = registeredReporter();

      reporter.sendTrackingEvent(AppStartTracking());

      expect(reporter.sentTrackingEvents, hasLength(1));
    });

    test(
      'should not keep sent events in memory when sent events are not kept',
      () {
        TrackingModuleConfigurator(
          false,
          keepsSentEvents: false,
        ).registerDependencies(serviceLocator);
        final reporter = registeredReporter();

        reporter.sendTrackingEvent(AppStartTracking());

        expect(reporter.sentTrackingEvents, isNull);
      },
    );
  });
}
