import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/call_booking/data/_data.dart';

import '../../../../../mock/feature/call_booking/test_data/call_booking_test_data.dart';

void main() {
  group('CallSlotsMapper', () {
    test('should read the slots as UTC times with their length and zone', () {
      final callSlots = const CallSlotsMapper().map(
        CallSlotsModel.fromJson(createCallSlotsJson()),
      );

      expect(callSlots, createCallSlotsEntity());
      expect(callSlots.slots.every((slot) => slot.isUtc), isTrue);
    });

    test('should throw a format exception for a slot that is not a time', () {
      expect(
        () => const CallSlotsMapper().map(
          CallSlotsModel(
            slots: ['next Tuesday'],
            slotMinutes: 30,
            timeZone: 'Europe/Madrid',
          ),
        ),
        throwsFormatException,
      );
    });
  });

  group('CallRequestMapper', () {
    test("should send the slot in UTC with the app's language", () {
      final callRequest = CallRequestMapper(
        AppLocale('es'),
      ).map(createCallRequestEntity());

      expect(callRequest.toJson(), {
        'slotStart': '2026-11-03T14:00:00.000Z',
        'name': 'Visitor Name',
        'email': 'visitor@example.com',
        'topic': 'App Development',
        'message': 'Looking for help.',
        'locale': 'es',
      });
    });

    test('should not print the visitor details when the model is logged', () {
      final callRequest = CallRequestMapper(
        AppLocale('en'),
      ).map(createCallRequestEntity());

      expect(callRequest.toString(), isNot(contains('visitor@example.com')));
    });
  });
}
