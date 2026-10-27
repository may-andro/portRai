import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';

class MockTrackingEventRepository extends Mock
    implements TrackingEventRepository {}

extension MockTrackingEventRepositoryStub on MockTrackingEventRepository {
  /// Stubs `getSentTrackingEvents()` to return [trackingEvents].
  void stubGetSentTrackingEvents(List<TrackingEventEntity>? trackingEvents) {
    when(getSentTrackingEvents).thenReturn(trackingEvents);
  }

  void stubGetSentTrackingEventsThrows(Object error) {
    when(getSentTrackingEvents).thenThrow(error);
  }
}
