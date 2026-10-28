import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

extension AppointmentSlotsExtension on AppointmentSlotsEntity {
  /// The slots in the device's time zone, grouped by their local day at
  /// midnight, both earliest first.
  Map<DateTime, List<DateTime>> get slotsByLocalDay {
    final slotsByDay = <DateTime, List<DateTime>>{};
    for (final slot in slots) {
      final localSlot = slot.toLocal();
      final day = DateTime(localSlot.year, localSlot.month, localSlot.day);
      (slotsByDay[day] ??= []).add(localSlot);
    }
    return slotsByDay;
  }
}

extension AppointmentDayExtension on DateTime {
  /// The day as a chip shows it, such as "Tue 3 Nov".
  String formattedAppointmentDay(BuildContext context) => DateFormat.MMMEd(
    Localizations.localeOf(context).toString(),
  ).format(this).capitalize;

  /// The day as the day picker lists it, such as "Tuesday, 3 November".
  String formattedAppointmentDayLong(BuildContext context) =>
      DateFormat.MMMMEEEEd(
        Localizations.localeOf(context).toString(),
      ).format(this).capitalize;

  /// The time of day in the device's time zone, such as "15:30".
  String formattedAppointmentTime(BuildContext context) => DateFormat.jm(
    Localizations.localeOf(context).toString(),
  ).format(toLocal());
}
