import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class UpdateAiImageSettingsFailure extends BasicFailure {
  const UpdateAiImageSettingsFailure({super.cause});
}

@Localizable('errorAiImageSettingsSave')
class UnknownUpdateAiImageSettingsFailure extends UpdateAiImageSettingsFailure {
  const UnknownUpdateAiImageSettingsFailure({super.cause});
}

@register
class UpdateAiImageSettingsUseCase
    extends BaseUseCase<void, AiImageSettings, UpdateAiImageSettingsFailure> {
  UpdateAiImageSettingsUseCase(this._repository);

  final AiImageSettingsRepository _repository;

  @protected
  @override
  FutureOr<Either<UpdateAiImageSettingsFailure, void>> execute(
    AiImageSettings settings,
  ) async {
    await _repository.setSettings(settings);
    return const Right(null);
  }

  @protected
  @override
  UpdateAiImageSettingsFailure mapErrorToFailure(Object e, StackTrace st) =>
      UnknownUpdateAiImageSettingsFailure(cause: e);
}
