import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/exception/_exception.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/repository/_repository.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/use_case/resolve_ai_image_request_settings_use_case.dart';
import 'package:portrai/src/feature/ai_rate_limit/ai_rate_limit.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:use_case/use_case.dart';

sealed class GenerateAiImageFailure extends BasicFailure {
  const GenerateAiImageFailure({super.cause});
}

class AiImageUnavailableFailure extends GenerateAiImageFailure {
  const AiImageUnavailableFailure({super.cause});
}

class AiImageFeatureDisabledFailure extends GenerateAiImageFailure {
  const AiImageFeatureDisabledFailure({super.cause});
}

class AiImageSourceFailure extends GenerateAiImageFailure {
  const AiImageSourceFailure({super.cause});
}

class AiImageGenerationFailure extends GenerateAiImageFailure {
  const AiImageGenerationFailure({super.cause});
}

class AiImageQuotaExceededFailure extends GenerateAiImageFailure {
  const AiImageQuotaExceededFailure({super.cause});
}

class AiImageUnknownFailure extends GenerateAiImageFailure {
  const AiImageUnknownFailure({super.cause});
}

abstract final class AiImageRequestLimits {
  static const promptVersion = 2;
  static const maxSourceImageBytes = 5 * 1024 * 1024;
  static const requestTimeout = Duration(seconds: 90);
  static const cacheDays = 30;
}

class GenerateAiImageParam extends Equatable {
  const GenerateAiImageParam({required this.sourceImageUrl});

  final String sourceImageUrl;

  @override
  List<Object?> get props => [sourceImageUrl];
}

@register
class GenerateAiImageUseCase
    extends
        BaseUseCase<
          AiImageEntity,
          GenerateAiImageParam,
          GenerateAiImageFailure
        > {
  GenerateAiImageUseCase(
    this._isFeatureEnabledUseCase,
    this._repository,
    this._resolveRequestSettingsUseCase,
    this._consumeAiRequestQuotaUseCase,
  );

  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final AiImageRepository _repository;
  final ResolveAiImageRequestSettingsUseCase _resolveRequestSettingsUseCase;
  final ConsumeAiRequestQuotaUseCase _consumeAiRequestQuotaUseCase;

  @protected
  @override
  Future<Either<GenerateAiImageFailure, AiImageEntity>> execute(
    GenerateAiImageParam param,
  ) async {
    final isFeatureEnabledEither = await _isFeatureEnabledUseCase(
      AiImageGenFeatureFlags.aiImageGeneration,
    );
    if (isFeatureEnabledEither.isLeft) {
      return Left(
        AiImageUnavailableFailure(cause: isFeatureEnabledEither.left),
      );
    }
    if (!isFeatureEnabledEither.right) {
      return const Left(AiImageFeatureDisabledFailure());
    }

    final requestSettings = (await _resolveRequestSettingsUseCase()).right;
    final cachedImage = await _repository.getCachedAiImage(
      sourceImageUrl: param.sourceImageUrl,
      prompt: requestSettings.prompt,
      model: requestSettings.model,
    );
    if (cachedImage != null) return Right(cachedImage);

    // Only a billable generation uses the AI budget, never a cached image. An
    // unreadable request log does not block generation.
    final consumeAiRequestQuotaEither = await _consumeAiRequestQuotaUseCase();
    if (consumeAiRequestQuotaEither.isLeft &&
        consumeAiRequestQuotaEither.left is AiRequestQuotaExceededFailure) {
      return Left(
        AiImageQuotaExceededFailure(cause: consumeAiRequestQuotaEither.left),
      );
    }

    final image = await _repository.generateAiImage(
      sourceImageUrl: param.sourceImageUrl,
      prompt: requestSettings.prompt,
      model: requestSettings.model,
    );
    return Right(image);
  }

  @protected
  @override
  GenerateAiImageFailure mapErrorToFailure(Object e, StackTrace st) {
    return switch (e) {
      AiImageSourceException() => AiImageSourceFailure(cause: e),
      AiImageGenerationException() => AiImageGenerationFailure(cause: e),
      _ => AiImageUnknownFailure(cause: e),
    };
  }
}
