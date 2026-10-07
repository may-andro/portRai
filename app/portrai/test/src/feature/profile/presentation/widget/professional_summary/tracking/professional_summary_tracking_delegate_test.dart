import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/tracking/_tracking.dart';
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

  group('ProfessionalSummaryTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ProfessionalSummaryTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ProfessionalSummaryTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test('should send a click event when trackExternalLinkClick is called', () {
      delegate.trackExternalLinkClick('Github');

      final tracking =
          verify(
                () => trackingReporter.sendTrackingEvent(captureAny()),
              ).captured.single
              as Tracking;

      expect(tracking.name, 'external_link');
      expect(tracking.parameters['label'], 'Github');
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
