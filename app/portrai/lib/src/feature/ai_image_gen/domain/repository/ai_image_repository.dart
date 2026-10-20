import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';

abstract class AiImageRepository {
  /// Returns the cached image generated from [sourceImageUrl], [prompt] and
  /// [model], or null when none is cached. Never generates.
  Future<AiImageEntity?> getCachedAiImage({
    required String sourceImageUrl,
    required String prompt,
    required String model,
  });

  /// Returns the cached image generated from [sourceImageUrl], [prompt] and [model],
  /// generating and caching a new one when none exists.
  Future<AiImageEntity> generateAiImage({
    required String sourceImageUrl,
    required String prompt,
    required String model,
  });
}
