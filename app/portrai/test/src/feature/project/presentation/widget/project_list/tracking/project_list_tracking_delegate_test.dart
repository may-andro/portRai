import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/tracking/_tracking.dart';
import 'package:tracking/tracking.dart';

import '../../../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ViewTracking(label: 'fallback'));
  });

  group('ProjectListTrackingDelegate', () {
    late MockTrackingReporter trackingReporter;
    late ProjectListTrackingDelegate delegate;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      delegate = ProjectListTrackingDelegate(trackingReporter);
      when(() => trackingReporter.sendTrackingEvent(any())).thenReturn(null);
    });

    test(
      'should send a project click with the element and item when an item tap is '
      'tracked',
      () {
        delegate.trackProjectClick(
          label: 'project_card',
          projectId: 'port-rai',
        );

        final tracking =
            verify(
                  () => trackingReporter.sendTrackingEvent(captureAny()),
                ).captured.single
                as Tracking;

        expect(tracking.name, 'project');
        expect(tracking.parameters['action'], 'click');
        expect(tracking.parameters['label'], 'project_card');
        expect(tracking.parameters['value'], 'port-rai');
      },
    );
  });
}
