import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

ReceivedAppointmentRequestEntity receivedAppointmentRequestEntityFixture({
  String id = 'request-1',
  DateTime? slotStart,
  String name = 'Alex Doe',
  String message = 'Looking forward to it.',
  AppointmentRequestStatus status = AppointmentRequestStatus.requested,
}) {
  final start = slotStart ?? DateTime.utc(2099, 11, 3, 14);
  return ReceivedAppointmentRequestEntity(
    id: id,
    slotStart: start,
    slotEnd: start.add(const Duration(minutes: 30)),
    name: name,
    email: 'alex@example.com',
    topic: 'Flutter consulting',
    message: message,
    status: status,
    createdAt: DateTime.utc(2026, 10, 28),
  );
}
