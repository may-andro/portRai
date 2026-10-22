import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/prepare_local_assistant_model_use_case.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/local_assistant/domain/repository/mock_local_assistant_repository.dart';
import '../../../../../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_supported_use_case.dart';
import '../../../../../mock/feature/permission/domain/use_case/mock_get_permission_status_use_case.dart';

void main() {
  setUpAll(() => registerFallbackValue((int _) {}));

  test(
    'should reject model preparation before reaching the repository when unsupported',
    () async {
      final repository = MockLocalAssistantRepository();
      final support = MockIsLocalAssistantSupportedUseCase()..stubCall(false);

      final result = await PrepareLocalAssistantModelUseCase(
        repository,
        support,
        MockGetPermissionStatusUseCase(),
      )((_) {});

      expect(result.left, isA<UnavailableLocalAssistantFailure>());
      verifyNever(
        () => repository.prepareModel(onProgress: any(named: 'onProgress')),
      );
    },
  );

  for (final (status, showsNotification) in [
    (AppPermissionStatus.granted, true),
    (AppPermissionStatus.denied, false),
    (AppPermissionStatus.permanentlyDenied, false),
  ]) {
    test('should show the download notification only when notifications are '
        '${status.name}', () async {
      final repository = MockLocalAssistantRepository();
      when(
        () => repository.prepareModel(
          onProgress: any(named: 'onProgress'),
          showsNotification: any(named: 'showsNotification'),
        ),
      ).thenAnswer((_) async {});

      await PrepareLocalAssistantModelUseCase(
        repository,
        MockIsLocalAssistantSupportedUseCase()..stubCall(true),
        MockGetPermissionStatusUseCase()
          ..stubCall(AppPermission.notifications, Right(status)),
      )((_) {});

      verify(
        () => repository.prepareModel(
          onProgress: any(named: 'onProgress'),
          showsNotification: showsNotification,
        ),
      ).called(1);
    });
  }
}
