import 'package:portrai/src/feature/schedule_appointment/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class ScheduleAppointmentModuleRoute extends ModuleRoute {
  ScheduleAppointmentModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
  });

  /// Takes an optional `topic` query parameter that fills in the topic.
  static final ScheduleAppointmentModuleRoute scheduleAppointment =
      ScheduleAppointmentModuleRoute._(
        name: 'schedule_appointment',
        path: '/schedule-appointment',
        builder: (_, _, _) => const ScheduleAppointmentScreen(),
      );
}
