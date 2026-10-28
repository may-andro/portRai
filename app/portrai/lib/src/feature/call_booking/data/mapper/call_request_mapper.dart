import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/call_booking/data/model/_model.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';

@register
class CallRequestMapper implements Mapper<CallRequestEntity, CallRequestModel> {
  const CallRequestMapper(this._appLocale);

  final AppLocale _appLocale;

  @override
  CallRequestModel map(CallRequestEntity from) {
    return CallRequestModel(
      slotStart: from.slotStart.toUtc().toIso8601String(),
      name: from.name,
      email: from.email,
      topic: from.topic,
      message: from.message,
      locale: _appLocale.languageCode,
    );
  }
}
