import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/schedule_appointment/data/model/_model.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';

@register
class AppointmentRequestMapper
    implements Mapper<AppointmentRequestEntity, AppointmentRequestModel> {
  const AppointmentRequestMapper(this._appLocale);

  final AppLocale _appLocale;

  @override
  AppointmentRequestModel map(AppointmentRequestEntity from) {
    return AppointmentRequestModel(
      slotStart: from.slotStart.toUtc().toIso8601String(),
      name: from.name,
      email: from.email,
      topic: from.topic,
      message: from.message,
      locale: _appLocale.languageCode,
    );
  }
}
