import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

class MockScheduleAppointmentRepository extends Mock
    implements ScheduleAppointmentRepository {}

extension MockScheduleAppointmentRepositoryStub
    on MockScheduleAppointmentRepository {
  void stubGetAppointmentSlots(AppointmentSlotsEntity appointmentSlots) {
    when(getAppointmentSlots).thenAnswer((_) async => appointmentSlots);
  }

  void stubGetAppointmentSlotsThrows(Object error) {
    when(getAppointmentSlots).thenThrow(error);
  }

  void stubRequestAppointment(String requestId) {
    when(() => requestAppointment(any())).thenAnswer((_) async => requestId);
  }

  void stubRequestAppointmentThrows(Object error) {
    when(() => requestAppointment(any())).thenThrow(error);
  }
}
