import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/update_local_assistant_enabled_use_case.dart';

import '../../../../../mock/feature/local_assistant/domain/repository/mock_local_assistant_repository.dart';
import '../../../../../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_supported_use_case.dart';

void main() {
  test(
    'should reject enabling before saving the preference when unsupported',
    () async {
      final repository = MockLocalAssistantRepository();
      final support = MockIsLocalAssistantSupportedUseCase()..stubCall(false);

      final result = await UpdateLocalAssistantEnabledUseCase(
        repository,
        support,
      )(true);

      expect(result.left, isA<UpdateLocalAssistantEnabledUnavailableFailure>());
      verifyNever(() => repository.setEnabled(enabled: true));
    },
  );

  test('should persist disabling without checking platform support', () async {
    final repository = MockLocalAssistantRepository();
    when(() => repository.setEnabled(enabled: false)).thenAnswer((_) async {});
    final support = MockIsLocalAssistantSupportedUseCase();

    final result = await UpdateLocalAssistantEnabledUseCase(
      repository,
      support,
    )(false);

    expect(result.isRight, isTrue);
    verify(() => repository.setEnabled(enabled: false)).called(1);
    verifyNever(() => support());
  });
}
