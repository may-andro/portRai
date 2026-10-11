import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/is_remote_assistant_supported_use_case.dart';
import 'package:use_case/use_case.dart';

class MockIsRemoteAssistantSupportedUseCase extends Mock
    implements IsRemoteAssistantSupportedUseCase {}

extension MockIsRemoteAssistantSupportedUseCaseStub
    on MockIsRemoteAssistantSupportedUseCase {
  void stubCall(Either<NoFailure, bool> result) {
    when(() => this()).thenAnswer((_) => Future.value(result));
  }
}
