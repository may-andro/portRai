import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:use_case/use_case.dart';

@register
class ResetLocalAssistantSessionUseCase
    extends BaseNoParamUseCase<void, LocalAssistantFailure> {
  ResetLocalAssistantSessionUseCase(this._repository);

  final LocalAssistantRepository _repository;

  @override
  Future<Either<LocalAssistantFailure, void>> execute() async {
    await _repository.resetSession();
    return const Right(null);
  }

  @override
  LocalAssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      e.toLocalAssistantFailure;
}
