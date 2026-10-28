import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/route/_route.dart';

void main() {
  test('should let visitors schedule without signing in', () {
    expect(
      ScheduleAppointmentModuleRoute.scheduleAppointment.requiresAuth,
      isFalse,
    );
  });

  test('should require sign-in for the requests when they show private '
      'data', () {
    final route = ScheduleAppointmentModuleRoute.appointmentRequests;
    expect(route.requiresAuth, isTrue);
    expect(route.path, '/appointment-requests');
  });
}
