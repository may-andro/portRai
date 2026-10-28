import 'package:portrai/src/feature/schedule_appointment/domain/entity/_entity.dart';

abstract interface class ScheduleAppointmentRepository {
  Future<AppointmentSlotsEntity> getAppointmentSlots();

  /// Books the slot of [request] and returns the request's ID.
  Future<String> requestAppointment(AppointmentRequestEntity request);
}
