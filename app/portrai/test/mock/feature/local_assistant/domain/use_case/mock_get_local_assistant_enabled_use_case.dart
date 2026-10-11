import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/get_local_assistant_enabled_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:use_case/use_case.dart';

class MockGetLocalAssistantEnabledUseCase extends Mock
    implements GetLocalAssistantEnabledUseCase {}

extension MockGetLocalAssistantEnabledUseCaseStub
    on MockGetLocalAssistantEnabledUseCase {
  void stubCall(Either<LocalAssistantFailure, bool> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
