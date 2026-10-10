import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:use_case/use_case.dart';

@register
class UpdateAssistantEnabledUseCase
    extends BaseUseCase<void, bool, AssistantFailure> {
  UpdateAssistantEnabledUseCase(this._repository);

  final AssistantRepository _repository;

  @protected
  @override
  FutureOr<Either<AssistantFailure, void>> execute(bool enabled) async {
    await _repository.setEnabled(enabled: enabled);
    return const Right(null);
  }

  @protected
  @override
  AssistantFailure mapErrorToFailure(Object e, StackTrace st) =>
      UnknownAssistantFailure(cause: e);
}
