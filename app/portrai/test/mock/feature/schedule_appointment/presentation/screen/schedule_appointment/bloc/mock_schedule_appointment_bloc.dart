import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/bloc/_bloc.dart';

class MockScheduleAppointmentBloc
    extends MockBloc<ScheduleAppointmentEvent, ScheduleAppointmentState>
    implements ScheduleAppointmentBloc {}

extension MockScheduleAppointmentBlocStub on MockScheduleAppointmentBloc {
  void stubState(ScheduleAppointmentState state) {
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      const Stream<ScheduleAppointmentState>.empty(),
      initialState: state,
    );
  }
}
