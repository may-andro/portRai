import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/remote_assistant/domain/entity/remote_assistant_preference_entity.dart';
import 'package:portrai/src/feature/remote_assistant/domain/extension/_extension.dart';
import 'package:portrai/src/feature/remote_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:use_case/use_case.dart';

@register
class GetRemoteAssistantPreferenceUseCase
    extends
        BaseNoParamUseCase<
          RemoteAssistantPreferenceEntity,
          RemoteAssistantFailure
        > {
  GetRemoteAssistantPreferenceUseCase(this._repository);

  final RemoteAssistantRepository _repository;

  @protected
  @override
  Future<Either<RemoteAssistantFailure, RemoteAssistantPreferenceEntity>>
  execute() async => Right(await _repository.getPreference());

  @protected
  @override
  RemoteAssistantFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => error.toRemoteAssistantFailure(
    unknownFailure: const RemoteAssistantPreferenceFailure(),
  );
}
