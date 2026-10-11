import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

class MockIsRemoteAssistantSupportedUseCase extends Mock
    implements IsRemoteAssistantSupportedUseCase {}

extension MockIsRemoteAssistantSupportedUseCaseStub
    on MockIsRemoteAssistantSupportedUseCase {
  void stubCall(bool supported) =>
      when(() => this()).thenAnswer((_) => Right<NoFailure, bool>(supported));
}
