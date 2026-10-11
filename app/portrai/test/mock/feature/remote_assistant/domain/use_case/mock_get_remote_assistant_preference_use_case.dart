import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/domain/entity/remote_assistant_preference_entity.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/get_remote_assistant_preference_use_case.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:use_case/use_case.dart';

class MockGetRemoteAssistantPreferenceUseCase extends Mock
    implements GetRemoteAssistantPreferenceUseCase {}

extension MockGetRemoteAssistantPreferenceUseCaseStub
    on MockGetRemoteAssistantPreferenceUseCase {
  void stubCall(
    Either<RemoteAssistantFailure, RemoteAssistantPreferenceEntity> result,
  ) {
    when(() => this()).thenAnswer((_) => result);
  }
}
