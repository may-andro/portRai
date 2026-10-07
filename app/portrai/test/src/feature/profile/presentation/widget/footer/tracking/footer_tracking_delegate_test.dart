import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      Tracking(
        name: 'fallback',
        action: const ClickAction(label: 'fallback'),
      ),
    );
  });

  group('FooterTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late FooterTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = FooterTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a click event when trackExternalLinkClick is called', () {
      delegate.trackExternalLinkClick('Resume');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'external_link');
      expect(tracking.parameters['label'], 'Resume');
      expect(tracking.parameters['action'], 'click');
    });

    test('should send a click event when trackEmailClick is called', () {
      delegate.trackEmailClick('mayank271993@gmail.com');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'email_click');
      expect(tracking.parameters['label'], 'mayank271993@gmail.com');
      expect(tracking.parameters['action'], 'click');
    });
  });
}
