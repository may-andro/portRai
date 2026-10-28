import 'package:portrai/src/feature/call_booking/domain/_domain.dart';

/// Tuesday 3 November 2026 at 15:00 and 15:30 in Madrid, and Wednesday at
/// 15:00.
final callSlotStarts = [
  DateTime.utc(2026, 11, 3, 14),
  DateTime.utc(2026, 11, 3, 14, 30),
  DateTime.utc(2026, 11, 4, 14),
];

CallSlotsEntity createCallSlotsEntity({List<DateTime>? slots}) {
  return CallSlotsEntity(
    slots: slots ?? callSlotStarts,
    slotDuration: const Duration(minutes: 30),
    ownerTimeZone: 'Europe/Madrid',
  );
}

Map<String, dynamic> createCallSlotsJson() {
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

CallRequestEntity createCallRequestEntity() {
  return CallRequestEntity(
    slotStart: callSlotStarts.first,
    name: 'Visitor Name',
    email: 'visitor@example.com',
    topic: 'App Development',
    message: 'Looking for help.',
  );
}
