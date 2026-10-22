import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:portrai/src/feature/permission/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/permission/permission.dart';

void main() {
  test('should map to the notification permission when asked for it', () {
    expect(
      const AppPermissionMapper().map(AppPermission.notifications),
      Permission.notification,
    );
  });
}
