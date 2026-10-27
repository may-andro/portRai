import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';

import '../../../../../mock/feature/developer_mode/domain/entity/tracking_event_entity_fixture.dart';
import '../../../../../mock/feature/developer_mode/domain/repository/mock_tracking_event_repository.dart';

void main() {
  group('GetTrackingEventsUseCase', () {
    late MockTrackingEventRepository trackingEventRepository;
    late GetTrackingEventsUseCase useCase;

    setUp(() {
      trackingEventRepository = MockTrackingEventRepository();
      useCase = GetTrackingEventsUseCase(trackingEventRepository);
    });

    test(
      'should return the events in send order when events are kept',
      () async {
        final firstTrackingEvent = trackingEventEntityFixture();
        final secondTrackingEvent = trackingEventEntityFixture(id: '2');
        trackingEventRepository.stubGetSentTrackingEvents([
          firstTrackingEvent,
          secondTrackingEvent,
        ]);

        final trackingEventsEither = await useCase();

        expect(trackingEventsEither.right, [
          firstTrackingEvent,
          secondTrackingEvent,
        ]);
      },
    );

    test('should return a not kept failure when events are not kept', () async {
      trackingEventRepository.stubGetSentTrackingEvents(null);

      final trackingEventsEither = await useCase();

      expect(trackingEventsEither.left, isA<TrackingEventsNotKeptFailure>());
    });

    test(
      'should return an unknown failure when reading the events throws',
      () async {
        trackingEventRepository.stubGetSentTrackingEventsThrows(
          StateError('x'),
        );

        final trackingEventsEither = await useCase();

        expect(trackingEventsEither.left, isA<TrackingEventsUnknownFailure>());
      },
    );
  });
}
