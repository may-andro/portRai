import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/domain/entity/remote_assistant_preference_entity.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/update_remote_assistant_preference_use_case.dart';
import 'package:use_case/use_case.dart';

class MockUpdateRemoteAssistantPreferenceUseCase extends Mock
    implements UpdateRemoteAssistantPreferenceUseCase {}

extension MockUpdateRemoteAssistantPreferenceUseCaseStub
    on MockUpdateRemoteAssistantPreferenceUseCase {
  void stubCall({
    required RemoteAssistantPreferenceEntity preference,
    required Either<RemoteAssistantFailure, void> result,
  }) {
    when(() => this(preference)).thenAnswer((_) => result);
  }
}
