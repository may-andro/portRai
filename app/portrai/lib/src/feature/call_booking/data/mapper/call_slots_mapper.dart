import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/call_booking/data/model/_model.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';

@register
class CallSlotsMapper implements Mapper<CallSlotsModel, CallSlotsEntity> {
  const CallSlotsMapper();

  /// Throws a [FormatException] when a slot is not an ISO 8601 time.
  @override
  CallSlotsEntity map(CallSlotsModel from) {
    return CallSlotsEntity(
      slots: from.slots.map((slot) => DateTime.parse(slot).toUtc()).toList(),
      slotDuration: Duration(minutes: from.slotMinutes),
      ownerTimeZone: from.timeZone,
    );
  }
}
