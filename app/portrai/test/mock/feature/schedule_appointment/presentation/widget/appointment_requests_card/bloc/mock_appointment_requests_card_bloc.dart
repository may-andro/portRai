import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/appointment_requests_card/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockAppointmentRequestsCardBloc
    extends MockBloc<AppointmentRequestsCardEvent, AppointmentRequestsCardState>
    implements AppointmentRequestsCardBloc {}

extension MockAppointmentRequestsCardBlocStub
    on MockAppointmentRequestsCardBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<AppointmentRequestsCardBloc>(() => this);
  }

  void stubState() {
    when(() => state).thenReturn(const AppointmentRequestsCardState());
    whenListen(
      this,
      const Stream<AppointmentRequestsCardState>.empty(),
      initialState: const AppointmentRequestsCardState(),
    );
  }
}
