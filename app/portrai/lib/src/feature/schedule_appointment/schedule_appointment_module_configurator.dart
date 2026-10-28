import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/route/_route.dart';
import 'package:portrai/src/feature/schedule_appointment/schedule_appointment_module_configurator.di.g.dart';
import 'package:portrai/src/route/route.dart';

/// The path the screen had before, still used by links shared earlier.
const formerScheduleAppointmentPath = '/book-call';

/// Sends the former path to the screen, keeping its query such as `topic`.
String? redirectFormerPath(Uri requestedUri) {
  if (requestedUri.path != formerScheduleAppointmentPath) return null;
  return requestedUri
      .replace(path: ScheduleAppointmentModuleRoute.scheduleAppointment.path)
      .toString();
}

@generateConfigurator
class ScheduleAppointmentModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerScheduleAppointmentDependencies(sl);

  @override
  void postDependenciesSetup(ServiceLocator sl) {
    sl.get<ModuleRouteController>()
      ..register(ScheduleAppointmentModuleRoute.scheduleAppointment)
      ..registerRedirect((_, requestedUri) => redirectFormerPath(requestedUri));

    final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
    for (final definition in ScheduleAppointmentFeatureFlags.all) {
      registry.register(definition);
    }
  }
}
