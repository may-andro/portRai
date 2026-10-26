import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetLocalAssistantEnabledFailure extends BasicFailure {
  const GetLocalAssistantEnabledFailure({super.cause});
}

@Localizable('assistantError')
class GetLocalAssistantEnabledUnknownFailure
    extends GetLocalAssistantEnabledFailure {
  const GetLocalAssistantEnabledUnknownFailure({super.cause});
}

@register
class GetLocalAssistantEnabledUseCase
    extends BaseNoParamUseCase<bool, GetLocalAssistantEnabledFailure> {
  GetLocalAssistantEnabledUseCase(this._repository);

  final LocalAssistantRepository _repository;

  @protected
  @override
  FutureOr<Either<GetLocalAssistantEnabledFailure, bool>> execute() async {
    return Right(await _repository.isEnabled());
  }

  @protected
  @override
  GetLocalAssistantEnabledFailure mapErrorToFailure(Object e, StackTrace st) =>
      GetLocalAssistantEnabledUnknownFailure(cause: e);
}
