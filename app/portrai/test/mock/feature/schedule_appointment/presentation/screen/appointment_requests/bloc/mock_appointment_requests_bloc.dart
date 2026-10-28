import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/_bloc.dart';

class MockAppointmentRequestsBloc
    extends MockBloc<AppointmentRequestsEvent, AppointmentRequestsState>
    implements AppointmentRequestsBloc {}

extension MockAppointmentRequestsBlocStub on MockAppointmentRequestsBloc {
  void stubState(AppointmentRequestsState state) {
    when(() => this.state).thenReturn(state);
  }
}
