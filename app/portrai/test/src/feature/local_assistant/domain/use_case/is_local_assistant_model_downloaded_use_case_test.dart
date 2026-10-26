import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/is_local_assistant_model_downloaded_use_case.dart';

import '../../../../../mock/feature/local_assistant/domain/repository/mock_local_assistant_repository.dart';
import '../../../../../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_supported_use_case.dart';

void main() {
  test(
    'should reject model inspection before reaching the repository when unsupported',
    () async {
      final repository = MockLocalAssistantRepository();
      final support = MockIsLocalAssistantSupportedUseCase()..stubCall(false);

      final result = await IsLocalAssistantModelDownloadedUseCase(
        repository,
        support,
      )();

      expect(
        result.left,
        isA<IsLocalAssistantModelDownloadedUnavailableFailure>(),
      );
      verifyNever(() => repository.isModelDownloaded());
    },
  );
}
