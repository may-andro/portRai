import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/domain/_domain.dart';

class MockPermissionRepository extends Mock implements PermissionRepository {}

extension MockPermissionRepositoryStub on MockPermissionRepository {
  void stubStatus(AppPermission permission, AppPermissionStatus status) {
    when(() => this.status(permission)).thenAnswer((_) async => status);
  }

  void stubRequest(AppPermission permission, AppPermissionStatus status) {
    when(() => request(permission)).thenAnswer((_) async => status);
  }
}
