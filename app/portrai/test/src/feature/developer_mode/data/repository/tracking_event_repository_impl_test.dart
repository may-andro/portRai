import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/data/_data.dart';
import 'package:tracking/tracking.dart';

import '../../../../../mock/utility/mock_tracking_reporter.dart';

void main() {
  group('TrackingEventRepositoryImpl', () {
    late MockTrackingReporter trackingReporter;
    late TrackingEventRepositoryImpl repository;

    setUp(() {
      trackingReporter = MockTrackingReporter();
      repository = TrackingEventRepositoryImpl(
        trackingReporter,
        const TrackingEventMapper(),
      );
    });

    test('should map every kept event in send order when events sent at '
        'the same time are kept', () {
      final sentAt = DateTime(2026, 10, 27, 14);
      when(() => trackingReporter.sentTrackingEvents).thenReturn([
        SentTracking(
          sequenceNumber: 0,
          sentAt: sentAt,
          tracking: ScreenViewTracking(area: SplashArea()),
        ),
        SentTracking(
          sequenceNumber: 1,
          sentAt: sentAt,
          tracking: ViewTracking(label: 'loaded_content_view'),
        ),
      ]);

      final trackingEvents = repository.getSentTrackingEvents();

      expect(trackingEvents?.map((trackingEvent) => trackingEvent.id), [
        '0',
        '1',
      ]);
      expect(trackingEvents?.map((trackingEvent) => trackingEvent.name), [
        'screen_view',
        'view_impression',
      ]);
    });

    test('should return null when events are not kept', () {
      when(() => trackingReporter.sentTrackingEvents).thenReturn(null);

      expect(repository.getSentTrackingEvents(), isNull);
    });
  });
}
