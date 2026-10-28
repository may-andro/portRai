import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/schedule_appointment/data/model/_model.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

@register
class AppointmentSlotsMapper
    implements Mapper<AppointmentSlotsModel, AppointmentSlotsEntity> {
  const AppointmentSlotsMapper();

  /// Throws a [FormatException] when a slot is not an ISO 8601 time.
  @override
  AppointmentSlotsEntity map(AppointmentSlotsModel from) {
    return AppointmentSlotsEntity(
      slots: from.slots.map((slot) => DateTime.parse(slot).toUtc()).toList(),
      slotDuration: Duration(minutes: from.slotMinutes),
      ownerTimeZone: from.timeZone,
    );
  }
}
