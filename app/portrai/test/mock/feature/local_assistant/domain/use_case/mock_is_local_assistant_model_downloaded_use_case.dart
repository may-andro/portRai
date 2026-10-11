import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/is_local_assistant_model_downloaded_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:use_case/use_case.dart';

class MockIsLocalAssistantModelDownloadedUseCase extends Mock
    implements IsLocalAssistantModelDownloadedUseCase {}

extension MockIsLocalAssistantModelDownloadedUseCaseStub
    on MockIsLocalAssistantModelDownloadedUseCase {
  void stubCall(Either<LocalAssistantFailure, bool> result) {
    when(() => this()).thenAnswer((_) => result);
  }
}
