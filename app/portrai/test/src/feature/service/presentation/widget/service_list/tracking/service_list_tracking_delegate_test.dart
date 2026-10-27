import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('ServiceListTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ServiceListTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ServiceListTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a service click with the item when an item tap is '
        'tracked', () {
      delegate.trackServiceClick('App Development');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'service');
      expect(tracking.parameters['action'], 'click');
      expect(tracking.parameters['label'], 'App Development');
    });
  });
}
