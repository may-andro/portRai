import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/remote_assistant/domain/entity/remote_assistant_preference_entity.dart';
import 'package:portrai/src/feature/remote_assistant/domain/repository/_repository.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure_mapper.dart';
import 'package:use_case/use_case.dart';

@register
class UpdateRemoteAssistantPreferenceUseCase
    extends
        BaseUseCase<
          void,
          RemoteAssistantPreferenceEntity,
          RemoteAssistantFailure
        > {
  UpdateRemoteAssistantPreferenceUseCase(this._repository);

  final RemoteAssistantRepository _repository;

  @protected
  @override
  Future<Either<RemoteAssistantFailure, void>> execute(
    RemoteAssistantPreferenceEntity preference,
  ) async {
    await _repository.updatePreference(preference);
    return const Right(null);
  }

  @protected
  @override
  RemoteAssistantFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => mapRemoteAssistantFailure(
    error,
    unknownFailure: const RemoteAssistantPreferenceFailure(),
  );
}
