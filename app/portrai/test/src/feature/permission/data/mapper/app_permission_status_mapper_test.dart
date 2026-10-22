import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:portrai/src/feature/permission/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/permission/permission.dart';

void main() {
  const mapper = AppPermissionStatusMapper();

  for (final (status, expected) in [
    (PermissionStatus.granted, AppPermissionStatus.granted),
    (PermissionStatus.limited, AppPermissionStatus.granted),
    (PermissionStatus.provisional, AppPermissionStatus.granted),
    (PermissionStatus.denied, AppPermissionStatus.denied),
    (PermissionStatus.permanentlyDenied, AppPermissionStatus.permanentlyDenied),
    (PermissionStatus.restricted, AppPermissionStatus.permanentlyDenied),
  ]) {
    test(
      'should map to ${expected.name} when the status is ${status.name}',
      () {
        expect(mapper.map(status), expected);
      },
    );
  }
}
