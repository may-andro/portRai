import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/schedule_appointment/data/model/_model.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

/// Throws a [FormatException] for a status the app does not know.
@register
class ReceivedAppointmentRequestMapper
    implements
        Mapper<
          ReceivedAppointmentRequestModel,
          ReceivedAppointmentRequestEntity
        > {
  const ReceivedAppointmentRequestMapper();

  @override
  ReceivedAppointmentRequestEntity map(ReceivedAppointmentRequestModel from) {
    return ReceivedAppointmentRequestEntity(
      id: from.id,
      slotStart: from.slotStart,
      slotEnd: from.slotEnd,
      name: from.name,
      email: from.email,
      topic: from.topic,
      message: from.message,
      status: AppointmentRequestStatus.values.firstWhere(
        (status) => status.name == from.status,
        orElse: () =>
            throw FormatException('Unknown request status: ${from.status}'),
      ),
      createdAt: from.createdAt,
    );
  }
}
