import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

/// Tuesday 3 November 2026 at 15:00 and 15:30 in Madrid, and Wednesday at
/// 15:00.
final appointmentSlotStarts = [
  DateTime.utc(2026, 11, 3, 14),
  DateTime.utc(2026, 11, 3, 14, 30),
  DateTime.utc(2026, 11, 4, 14),
];

AppointmentSlotsEntity createAppointmentSlotsEntity({List<DateTime>? slots}) {
  return AppointmentSlotsEntity(
    slots: slots ?? appointmentSlotStarts,
    slotDuration: const Duration(minutes: 30),
    ownerTimeZone: 'Europe/Madrid',
  );
}

Map<String, dynamic> createAppointmentSlotsJson() {
  return {
    'slots': [
      '2026-11-03T14:00:00.000Z',
      '2026-11-03T14:30:00.000Z',
      '2026-11-04T14:00:00.000Z',
    ],
    'slotMinutes': 30,
    'timeZone': 'Europe/Madrid',
  };
}

AppointmentRequestEntity createAppointmentRequestEntity() {
  return AppointmentRequestEntity(
    slotStart: appointmentSlotStarts.first,
    name: 'Visitor Name',
    email: 'visitor@example.com',
    topic: 'App Development',
    message: 'Looking for help.',
  );
}
