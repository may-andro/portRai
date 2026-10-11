import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/prepare_local_assistant_model_use_case.dart';
import 'package:use_case/use_case.dart';

class MockPrepareLocalAssistantModelUseCase extends Mock
    implements PrepareLocalAssistantModelUseCase {}

extension MockPrepareLocalAssistantModelUseCaseStub
    on MockPrepareLocalAssistantModelUseCase {
  void stubCall(Either<LocalAssistantFailure, void> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
