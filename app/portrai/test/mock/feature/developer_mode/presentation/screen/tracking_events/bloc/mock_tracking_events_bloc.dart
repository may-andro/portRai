import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/bloc/_bloc.dart';

class MockTrackingEventsBloc
    extends MockBloc<TrackingEventsEvent, TrackingEventsState>
    implements TrackingEventsBloc {}

extension MockTrackingEventsBlocStub on MockTrackingEventsBloc {
  void stubState(TrackingEventsState state) {
    when(() => this.state).thenReturn(state);
  }
}
