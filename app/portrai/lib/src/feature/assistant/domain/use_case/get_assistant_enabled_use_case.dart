import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:use_case/use_case.dart';

@register
class GetAssistantEnabledUseCase
    extends BaseNoParamUseCase<bool, AssistantFailure> {
  GetAssistantEnabledUseCase(this._repository);

  final AssistantRepository _repository;

  @protected
  @override
  FutureOr<Either<AssistantFailure, bool>> execute() async {
    return Right(await _repository.isEnabled());
  }

  @protected
  @override
  AssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      UnknownAssistantFailure(cause: e);
}
