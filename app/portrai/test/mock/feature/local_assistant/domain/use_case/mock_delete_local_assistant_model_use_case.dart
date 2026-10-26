import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/delete_local_assistant_model_use_case.dart';
import 'package:use_case/use_case.dart';

class MockDeleteLocalAssistantModelUseCase extends Mock
    implements DeleteLocalAssistantModelUseCase {}

extension MockDeleteLocalAssistantModelUseCaseStub
    on MockDeleteLocalAssistantModelUseCase {
  void stubCall(Either<DeleteLocalAssistantModelFailure, void> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
