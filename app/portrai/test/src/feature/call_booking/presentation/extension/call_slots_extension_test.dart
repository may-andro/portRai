import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/call_booking/presentation/extension/_extension.dart';

import '../../../../../mock/feature/call_booking/test_data/call_booking_test_data.dart';

void main() {
  group('CallSlotsExtension', () {
    test('should group the slots by their local day, earliest first', () {
      final slotsByDay = createCallSlotsEntity().slotsByLocalDay;

      final expectedDays = {
        for (final slot in callSlotStarts)
          DateTime(
            slot.toLocal().year,
            slot.toLocal().month,
            slot.toLocal().day,
          ),
      };
      expect(slotsByDay.keys, orderedEquals(expectedDays));
      expect(
        slotsByDay.values.expand((slots) => slots),
        orderedEquals(callSlotStarts.map((slot) => slot.toLocal())),
      );
    });

    test('should have no days when there are no slots', () {
      expect(createCallSlotsEntity(slots: []).slotsByLocalDay, isEmpty);
    });
  });
}
