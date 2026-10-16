import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

/// Returns null when no selection is stored or it can't be read.
@register
class GetAiImageSettingsUseCase
    extends BaseNoParamUseCase<AiImageSettings?, NoFailure> {
  GetAiImageSettingsUseCase(this._repository);

  final AiImageSettingsRepository _repository;

  @protected
  @override
  FutureOr<Either<NoFailure, AiImageSettings?>> execute() async {
    try {
      return Right(await _repository.getSettings());
    } catch (_) {
      return const Right(null);
    }
  }

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
