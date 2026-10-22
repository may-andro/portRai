import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/permission.dart';

import '../../../../../mock/feature/permission/domain/repository/mock_permission_repository.dart';

void main() {
  test('should succeed when the settings open', () async {
    final repository = MockPermissionRepository();
    when(repository.openSettings).thenAnswer((_) async => true);

    final result = await OpenPermissionSettingsUseCase(repository)();

    expect(result.isRight, isTrue);
  });

  test('should return a failure when the settings do not open', () async {
    final repository = MockPermissionRepository();
    when(repository.openSettings).thenAnswer((_) async => false);

    final result = await OpenPermissionSettingsUseCase(repository)();

    expect(result.left, isA<OpenPermissionSettingsUnknownFailure>());
  });
}
