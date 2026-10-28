import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockScheduleAppointmentEntryBloc
    extends
        MockBloc<ScheduleAppointmentEntryEvent, ScheduleAppointmentEntryState>
    implements ScheduleAppointmentEntryBloc {}

extension MockScheduleAppointmentEntryBlocStub
    on MockScheduleAppointmentEntryBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<ScheduleAppointmentEntryBloc>(() => this);
  }

  void stubAvailable(bool isAvailable) {
    final state = ScheduleAppointmentEntryState(isAvailable: isAvailable);
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      const Stream<ScheduleAppointmentEntryState>.empty(),
      initialState: state,
    );
  }
}
