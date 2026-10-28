import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/extension/_extension.dart';

import '../../../../../mock/feature/schedule_appointment/test_data/schedule_appointment_test_data.dart';

void main() {
  group('AppointmentSlotsExtension', () {
    test('should group the slots by their local day, earliest first', () {
      final slotsByDay = createAppointmentSlotsEntity().slotsByLocalDay;

      final expectedDays = {
        for (final slot in appointmentSlotStarts)
          DateTime(
            slot.toLocal().year,
            slot.toLocal().month,
            slot.toLocal().day,
          ),
      };
      expect(slotsByDay.keys, orderedEquals(expectedDays));
      expect(
        slotsByDay.values.expand((slots) => slots),
        orderedEquals(appointmentSlotStarts.map((slot) => slot.toLocal())),
      );
    });

    test('should have no days when there are no slots', () {
      expect(createAppointmentSlotsEntity(slots: []).slotsByLocalDay, isEmpty);
    });
  });
}
