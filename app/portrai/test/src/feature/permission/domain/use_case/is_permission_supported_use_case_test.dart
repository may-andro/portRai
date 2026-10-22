import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/permission.dart';

import '../../../../../mock/feature/permission/domain/repository/mock_permission_repository.dart';

void main() {
  for (final isSupported in [true, false]) {
    test('should return $isSupported when the platform says so', () async {
      final repository = MockPermissionRepository();
      when(
        () => repository.isSupported(AppPermission.notifications),
      ).thenReturn(isSupported);

      final result = await IsPermissionSupportedUseCase(repository)(
        AppPermission.notifications,
      );

      expect(result.right, isSupported);
    });
  }
}
