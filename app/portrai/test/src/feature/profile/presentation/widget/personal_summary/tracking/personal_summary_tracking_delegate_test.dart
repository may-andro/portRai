import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('PersonalSummaryTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late PersonalSummaryTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = PersonalSummaryTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test(
      'should send a profile click when the view profile tap is tracked',
      () {
        delegate.trackViewProfileClick('view_profile_button');

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.name, 'profile');
        expect(tracking.parameters['action'], 'click');
        expect(tracking.parameters['label'], 'view_profile_button');
      },
    );
  });
}
