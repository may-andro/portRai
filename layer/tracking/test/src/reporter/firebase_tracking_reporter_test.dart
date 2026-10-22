import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tracking/src/model/model.dart';
import 'package:tracking/src/reporter/reporter.dart';

import '../../_mock/mock_fb_analytics_controller.dart';

void main() {
  group(FirebaseTrackingReporter, () {
    late FirebaseTrackingReporter reporter;

    late MockFbAnalyticsController mockFbAnalyticsController;

    setUp(() {
      mockFbAnalyticsController = MockFbAnalyticsController()
        ..mockSendLogEvent();

      reporter = FirebaseTrackingReporter(mockFbAnalyticsController);
    });

    group('sendTrackingEvent', () {
      test('should store Tracking when sent', () {
        reporter.sendTrackingEvent(AppStartTracking());

        verify(
          () => mockFbAnalyticsController.sendLogEvent(
            'app_started',
            parameters: {
              'event': 'app_started',
              'area': 'splash',
              'action': 'setup',
              'status': 'uninitialised',
            },
          ),
        ).called(1);
      });
    });

    group('sentTrackingEvents', () {
      test('should not cache sent events', () {
        expect(reporter.sentTrackingEvents, isNull);
      });
    });
  });
}
