import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class ResetLocalAssistantSessionFailure extends BasicFailure {
  const ResetLocalAssistantSessionFailure({super.cause});
}

@Localizable('assistantError')
class ResetLocalAssistantSessionUnknownFailure
    extends ResetLocalAssistantSessionFailure {
  const ResetLocalAssistantSessionUnknownFailure({super.cause});
}

@register
class ResetLocalAssistantSessionUseCase
    extends BaseNoParamUseCase<void, ResetLocalAssistantSessionFailure> {
  ResetLocalAssistantSessionUseCase(this._repository);

  final LocalAssistantRepository _repository;

  @override
  Future<Either<ResetLocalAssistantSessionFailure, void>> execute() async {
    await _repository.resetSession();
    return const Right(null);
  }

  @override
  ResetLocalAssistantSessionFailure mapErrorToFailure(
    Object e,
    StackTrace st,
  ) => ResetLocalAssistantSessionUnknownFailure(cause: e);
}
