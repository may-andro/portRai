import 'package:flutter_test/flutter_test.dart';
import 'package:tracking/src/model/model.dart';
import 'package:tracking/src/reporter/reporter.dart';

void main() {
  group(LocalTrackingReporter, () {
    late LocalTrackingReporter reporter;

    setUp(() {
      reporter = LocalTrackingReporter();
    });

    group('sendTrackingEvent', () {
      test('should store event when sent', () {
        final event = AppStartTracking();
        reporter.sendTrackingEvent(event);

        expect(reporter.sentTrackingEvents?.length, equals(1));
        expect(reporter.sentTrackingEvents?.first.tracking, equals(event));
      });
    });

    group('sentTrackingEvents', () {
      test('should has no sent events initially', () {
        expect(reporter.sentTrackingEvents, isEmpty);
      });

      test('should keep every event in send order when events are sent at '
          'the same time', () {
        final events = [
          for (var eventIndex = 0; eventIndex < 50; eventIndex++)
            ClickTracking(label: '$eventIndex'),
        ];

        events.forEach(reporter.sendTrackingEvent);

        expect(
          reporter.sentTrackingEvents?.map((sent) => sent.tracking),
          events,
        );
        expect(
          reporter.sentTrackingEvents?.map((sent) => sent.sequenceNumber),
          List.generate(events.length, (eventIndex) => eventIndex),
        );
      });

      test('should keep only the most recent events and their sequence '
          'numbers when over the limit', () {
        final boundedReporter = LocalTrackingReporter(maxEvents: 2);
        final latestEvent = ScreenViewTracking(area: SplashArea());

        boundedReporter.sendTrackingEvent(AppStartTracking());
        boundedReporter.sendTrackingEvent(AppStartTracking());
        boundedReporter.sendTrackingEvent(latestEvent);

        expect(boundedReporter.sentTrackingEvents?.length, equals(2));
        expect(boundedReporter.sentTrackingEvents?.last.tracking, latestEvent);
        expect(
          boundedReporter.sentTrackingEvents?.map(
            (sent) => sent.sequenceNumber,
          ),
          [1, 2],
        );
      });
    });
  });
}
