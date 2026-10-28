import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/schedule_appointment/data/_data.dart';

import '../../../../../mock/feature/schedule_appointment/test_data/schedule_appointment_test_data.dart';

void main() {
  group('AppointmentSlotsMapper', () {
    test('should read the slots as UTC times with their length and zone', () {
      final appointmentSlots = const AppointmentSlotsMapper().map(
        AppointmentSlotsModel.fromJson(createAppointmentSlotsJson()),
      );

      expect(appointmentSlots, createAppointmentSlotsEntity());
      expect(appointmentSlots.slots.every((slot) => slot.isUtc), isTrue);
    });

    test('should throw a format exception for a slot that is not a time', () {
      expect(
        () => const AppointmentSlotsMapper().map(
          AppointmentSlotsModel(
            slots: ['next Tuesday'],
            slotMinutes: 30,
            timeZone: 'Europe/Madrid',
          ),
        ),
        throwsFormatException,
      );
    });
  });

  group('AppointmentRequestMapper', () {
    test("should send the slot in UTC with the app's language", () {
      final appointmentRequest = AppointmentRequestMapper(
        AppLocale('es'),
      ).map(createAppointmentRequestEntity());

      expect(appointmentRequest.toJson(), {
        'slotStart': '2026-11-03T14:00:00.000Z',
        'name': 'Visitor Name',
        'email': 'visitor@example.com',
        'topic': 'App Development',
        'message': 'Looking for help.',
        'locale': 'es',
      });
    });

    test('should not print the visitor details when the model is logged', () {
      final appointmentRequest = AppointmentRequestMapper(
        AppLocale('en'),
      ).map(createAppointmentRequestEntity());

      expect(
        appointmentRequest.toString(),
        isNot(contains('visitor@example.com')),
      );
    });
  });
}
