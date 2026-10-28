import 'package:portrai/src/feature/schedule_appointment/presentation/screen/_screen.dart';
import 'package:portrai/src/route/route.dart';

class ScheduleAppointmentModuleRoute extends ModuleRoute {
  ScheduleAppointmentModuleRoute._({
    required super.name,
    required super.path,
    required super.builder,
    super.requiresAuth,
  });

  /// Takes an optional `topic` query parameter that fills in the topic.
  static final ScheduleAppointmentModuleRoute scheduleAppointment =
      ScheduleAppointmentModuleRoute._(
        name: 'schedule_appointment',
        path: '/schedule-appointment',
        builder: (_, _, _) => const ScheduleAppointmentScreen(),
      );

  /// The owner's requests are private, so the route requires a signed-in
  /// user.
  static final ScheduleAppointmentModuleRoute appointmentRequests =
      ScheduleAppointmentModuleRoute._(
        name: 'appointment_requests',
        path: '/appointment-requests',
        builder: (_, _, _) => const AppointmentRequestsScreen(),
        requiresAuth: true,
      );
}
