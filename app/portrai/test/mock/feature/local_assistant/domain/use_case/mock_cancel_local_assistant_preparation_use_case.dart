import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/cancel_local_assistant_preparation_use_case.dart';
import 'package:use_case/use_case.dart';

class MockCancelLocalAssistantPreparationUseCase extends Mock
    implements CancelLocalAssistantPreparationUseCase {}

extension MockCancelLocalAssistantPreparationUseCaseStub
    on MockCancelLocalAssistantPreparationUseCase {
  void stubCall(Either<CancelLocalAssistantPreparationFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
