import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

/// Feature flags owned by the `schedule_appointment` feature.
abstract final class ScheduleAppointmentFeatureFlags {
  static const scheduleAppointment = AppFeatureFlagDefinition(
    key: 'feature_call_booking',
    defaultValue: false,
    displayName: 'Schedule Appointment',
    description:
        'Shows Schedule an Appointment buttons, which let visitors pick a free '
        'time and request an appointment with the owner',
  );

  static const all = [scheduleAppointment];
}
