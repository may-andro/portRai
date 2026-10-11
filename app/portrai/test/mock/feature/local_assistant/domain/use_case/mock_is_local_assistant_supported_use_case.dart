import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:use_case/use_case.dart';

class MockIsLocalAssistantSupportedUseCase extends Mock
    implements IsLocalAssistantSupportedUseCase {}

extension MockIsLocalAssistantSupportedUseCaseStub
    on MockIsLocalAssistantSupportedUseCase {
  void stubCall(bool supported) =>
      when(() => this()).thenAnswer((_) => Right<NoFailure, bool>(supported));
}
