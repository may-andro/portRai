import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/exception/_exception.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class RemoveAiImageBackgroundFailure extends BasicFailure {
  const RemoveAiImageBackgroundFailure({super.cause});
}

class AiImageProcessingFailure extends RemoveAiImageBackgroundFailure {
  const AiImageProcessingFailure({super.cause});
}

class RemoveAiImageBackgroundUnknownFailure
    extends RemoveAiImageBackgroundFailure {
  const RemoveAiImageBackgroundUnknownFailure({super.cause});
}

/// Makes the plain light backdrop of an image transparent, so features that
/// draw it over their own background can opt in.
@register
class RemoveAiImageBackgroundUseCase
    extends
        BaseUseCase<
          AiImageEntity,
          AiImageEntity,
          RemoveAiImageBackgroundFailure
        > {
  RemoveAiImageBackgroundUseCase(this._repository);

  final AiImageProcessingRepository _repository;

  @protected
  @override
  Future<Either<RemoveAiImageBackgroundFailure, AiImageEntity>> execute(
    AiImageEntity param,
  ) async => Right(await _repository.removeBackground(param));

  @protected
  @override
  RemoveAiImageBackgroundFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      AiImageProcessingException() => AiImageProcessingFailure(cause: e),
      _ => RemoveAiImageBackgroundUnknownFailure(cause: e),
    };
  }
}
