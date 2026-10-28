import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/schedule_appointment/schedule_appointment_module_configurator.dart';

void main() {
  group('redirectFormerPath', () {
    test('should send the former path to the screen with its query', () {
      expect(
        redirectFormerPath(Uri.parse('/book-call?topic=App%20Development')),
        '/schedule-appointment?topic=App%20Development',
      );
    });

    test('should send the former path without a query to the screen', () {
      expect(
        redirectFormerPath(Uri.parse('/book-call')),
        '/schedule-appointment',
      );
    });

    test('should keep every other path', () {
      expect(redirectFormerPath(Uri.parse('/schedule-appointment')), isNull);
      expect(redirectFormerPath(Uri.parse('/')), isNull);
    });
  });
}
