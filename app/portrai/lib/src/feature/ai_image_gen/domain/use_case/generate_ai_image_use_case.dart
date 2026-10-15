import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/exception/_exception.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/repository/_repository.dart';
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

class AiImageUnknownFailure extends GenerateAiImageFailure {
  const AiImageUnknownFailure({super.cause});
}

abstract final class AiImageRequestLimits {
  static const model = 'gemini-2.5-flash-image';
  static const promptVersion = 1;
  static const maxSourceImageBytes = 5 * 1024 * 1024;
  static const requestTimeout = Duration(seconds: 90);
  static const cacheDays = 30;
}

abstract final class AiImagePrompts {
  /// Turns a portrait photo into the portfolio's hand-drawn anime avatar.
  static const avatar =
      'Redraw the person in the supplied photo as a hand-drawn anime-style '
      'character illustration, in a cel-shaded 2D animation look similar to '
      'a Studio Ghibli character portrait. '
      'Style: clean, confident dark outlines of uniform weight; flat colour '
      'fills with simple soft cel shading and no gradients, textures or '
      'photographic detail; warm natural skin tones. '
      'Face: keep the likeness of the person, including hair style and '
      'colour, facial hair, face shape, skin tone and expression. Draw large, '
      'round, expressive dark-brown anime eyes with a small white highlight, '
      'simple defined eyebrows, a simple nose line and a friendly smile that '
      'shows the teeth. '
      'Clothing: keep the same clothes and colours as the photo, drawn with '
      'flat colours, visible seams, collar folds and buttons. '
      'Composition: front-facing, head and shoulders, centred, with the '
      'shoulders reaching the left, right and bottom edges of the frame and a '
      'little space above the hair. Square 1:1 image. '
      'Background: plain solid pure white (#FFFFFF) filling every pixel outside '
      'the character, with no shadows, gradients, patterns, ground or objects, '
      'because it is removed afterwards to make the image transparent. Do not '
      'use white or near-white for the outer edge of the clothes or hair; '
      'keep the dark outline closed around the whole character. '
      'Do not include any text, letters, logos, watermarks, frames or '
      'borders.';
}

class GenerateAiImageParam extends Equatable {
  const GenerateAiImageParam({
    required this.sourceImageUrl,
    this.prompt = AiImagePrompts.avatar,
  });

  final String sourceImageUrl;
  final String prompt;

  @override
  List<Object> get props => [sourceImageUrl, prompt];
}

@register
class GenerateAiImageUseCase
    extends
        BaseUseCase<
          AiImageEntity,
          GenerateAiImageParam,
          GenerateAiImageFailure
        > {
  GenerateAiImageUseCase(this._isFeatureEnabledUseCase, this._repository);

  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final AiImageRepository _repository;

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

    final image = await _repository.generateAiImage(
      sourceImageUrl: param.sourceImageUrl,
      prompt: param.prompt,
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
