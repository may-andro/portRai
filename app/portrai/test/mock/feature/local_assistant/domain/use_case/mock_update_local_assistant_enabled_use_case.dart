import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/update_local_assistant_enabled_use_case.dart';
import 'package:use_case/use_case.dart';

class MockUpdateLocalAssistantEnabledUseCase extends Mock
    implements UpdateLocalAssistantEnabledUseCase {}

extension MockUpdateLocalAssistantEnabledUseCaseStub
    on MockUpdateLocalAssistantEnabledUseCase {
  void stubCall(Either<UpdateLocalAssistantEnabledFailure, void> result) {
    when(() => this(any())).thenAnswer((_) => result);
  }
}
