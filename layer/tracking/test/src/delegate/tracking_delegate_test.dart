import 'package:flutter_test/flutter_test.dart';
import 'package:tracking/src/delegate/delegate.dart';
import 'package:tracking/src/model/model.dart';
import 'package:tracking/src/reporter/reporter.dart';

class _TestArea extends TrackingArea {
  const _TestArea() : super('test_area');
}

class _TestScreenTrackingDelegate extends ScreenTrackingDelegate {
  _TestScreenTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TestArea(), trackingReporter);
}

void main() {
  group(ScreenTrackingDelegate, () {
    late LocalTrackingReporter reporter;
    late _TestScreenTrackingDelegate delegate;

    setUp(() {
      reporter = LocalTrackingReporter();
      delegate = _TestScreenTrackingDelegate(reporter);
    });

    test(
      'should send a screen view for its area when the screen is viewed',
      () {
        delegate.trackScreenView();

        final event = reporter.sentTrackingEvents!.values.single;
        expect(event, isA<ScreenViewTracking>());
      },
    );

    test(
      'should send a view impression with the label when a view is seen',
      () {
        delegate.trackViewEvent('loaded_content_view');

        final event = reporter.sentTrackingEvents!.values.single;
        expect(event, isA<ViewTracking>());
        expect(
          event.action,
          isA<ViewAction>().having(
            (action) => action.label,
            'label',
            'loaded_content_view',
          ),
        );
      },
    );
  });
}
