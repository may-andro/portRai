import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/permission.dart';

import '../../../../../mock/feature/permission/domain/repository/mock_permission_repository.dart';

void main() {
  const permission = AppPermission.notifications;

  test('should ask the user when the permission is not decided', () async {
    final repository = MockPermissionRepository()
      ..stubStatus(permission, AppPermissionStatus.denied)
      ..stubRequest(permission, AppPermissionStatus.granted);

    final result = await RequestPermissionUseCase(repository)(permission);

    expect(result.right, AppPermissionStatus.granted);
    verify(() => repository.request(permission)).called(1);
  });

  for (final status in [
    AppPermissionStatus.granted,
    AppPermissionStatus.permanentlyDenied,
  ]) {
    test(
      'should not ask the user when the permission is ${status.name}',
      () async {
        final repository = MockPermissionRepository()
          ..stubStatus(permission, status);

        final result = await RequestPermissionUseCase(repository)(permission);

        expect(result.right, status);
        verifyNever(() => repository.request(permission));
      },
    );
  }

  test('should return a failure when the prompt cannot be shown', () async {
    final repository = MockPermissionRepository()
      ..stubStatus(permission, AppPermissionStatus.denied);
    when(
      () => repository.request(permission),
    ).thenThrow(StateError('No activity'));

    final result = await RequestPermissionUseCase(repository)(permission);

    expect(result.left, isA<RequestPermissionUnknownFailure>());
  });
}
