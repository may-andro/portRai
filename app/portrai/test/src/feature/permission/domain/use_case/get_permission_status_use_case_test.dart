import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/permission.dart';

import '../../../../../mock/feature/permission/domain/repository/mock_permission_repository.dart';

void main() {
  const permission = AppPermission.notifications;

  test('should return the status without asking when it is read', () async {
    final repository = MockPermissionRepository()
      ..stubStatus(permission, AppPermissionStatus.denied);

    final result = await GetPermissionStatusUseCase(repository)(permission);

    expect(result.right, AppPermissionStatus.denied);
    verifyNever(() => repository.request(permission));
  });

  test('should return a failure when the status cannot be read', () async {
    final repository = MockPermissionRepository();
    when(
      () => repository.status(permission),
    ).thenThrow(StateError('Unavailable'));

    final result = await GetPermissionStatusUseCase(repository)(permission);

    expect(result.left, isA<GetPermissionStatusUnknownFailure>());
  });
}
