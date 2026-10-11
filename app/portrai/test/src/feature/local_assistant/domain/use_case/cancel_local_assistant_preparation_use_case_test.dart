import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/cancel_local_assistant_preparation_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';

import '../../../../../mock/feature/local_assistant/domain/repository/mock_local_assistant_repository.dart';
import '../../../../../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_supported_use_case.dart';

void main() {
  test(
    'should reject native preparation cancellation before reaching the repository when unsupported',
    () async {
      final repository = MockLocalAssistantRepository();
      final support = MockIsLocalAssistantSupportedUseCase()..stubCall(false);

      final result = await CancelLocalAssistantPreparationUseCase(
        repository,
        support,
      )();

      expect(result.left, isA<UnavailableLocalAssistantFailure>());
      verifyNever(() => repository.cancelPreparation());
    },
  );
}
