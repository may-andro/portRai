import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/prepare_local_assistant_model_use_case.dart';

import '../../../../../mock/feature/local_assistant/domain/repository/mock_local_assistant_repository.dart';
import '../../../../../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_supported_use_case.dart';

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
      )((_) {});

      expect(result.left, isA<UnavailableLocalAssistantFailure>());
      verifyNever(
        () => repository.prepareModel(onProgress: any(named: 'onProgress')),
      );
    },
  );
}
