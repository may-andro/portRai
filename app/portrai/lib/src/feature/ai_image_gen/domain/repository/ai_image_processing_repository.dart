import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';

abstract class AiImageProcessingRepository {
  /// Returns [image] with its plain light backdrop made transparent.
  Future<AiImageEntity> removeBackground(AiImageEntity image);
}
