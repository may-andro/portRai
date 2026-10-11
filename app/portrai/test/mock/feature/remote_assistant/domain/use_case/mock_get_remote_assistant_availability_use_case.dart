import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

class MockGetRemoteAssistantAvailabilityUseCase extends Mock
    implements GetRemoteAssistantAvailabilityUseCase {}

extension MockGetRemoteAssistantAvailabilityUseCaseStub
    on MockGetRemoteAssistantAvailabilityUseCase {
  void stubCall(AssistantAvailabilityEntity availability) =>
      when(() => this()).thenAnswer(
        (_) => Right<IsFeatureEnabledFailure, AssistantAvailabilityEntity>(
          availability,
        ),
      );
}
