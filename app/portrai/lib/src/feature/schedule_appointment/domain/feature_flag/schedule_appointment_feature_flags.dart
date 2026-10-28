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

  static const appointmentRequests = AppFeatureFlagDefinition(
    key: 'feature_appointment_requests',
    defaultValue: false,
    displayName: 'Appointment Requests',
    description:
        'Shows the Appointment requests card in Settings, which opens the '
        "signed-in owner's requests to accept or decline",
  );

  static const all = [scheduleAppointment, appointmentRequests];
}
