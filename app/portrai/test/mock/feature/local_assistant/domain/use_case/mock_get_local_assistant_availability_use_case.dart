import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:use_case/use_case.dart';

class MockGetLocalAssistantAvailabilityUseCase extends Mock
    implements GetLocalAssistantAvailabilityUseCase {}

extension MockGetLocalAssistantAvailabilityUseCaseStub
    on MockGetLocalAssistantAvailabilityUseCase {
  void stubCall(AssistantAvailabilityEntity availability) =>
      when(() => this()).thenAnswer(
        (_) => Right<IsFeatureEnabledFailure, AssistantAvailabilityEntity>(
          availability,
        ),
      );
}
