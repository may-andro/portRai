import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/data/model/_model.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';

/// Maps cached [AiImageModel]s to [AiImageEntity]s.
///
/// Doesn't implement `BiMapper` because the reverse direction needs the cache
/// key, which the entity does not carry.
@register
class AiImageMapper implements Mapper<AiImageModel, AiImageEntity> {
  const AiImageMapper();

  @override
  AiImageEntity map(AiImageModel from) =>
      AiImageEntity(bytes: from.bytes, mimeType: from.mimeType);

  AiImageModel toModel(AiImageEntity entity, {required String key}) =>
      AiImageModel(key: key, mimeType: entity.mimeType, bytes: entity.bytes);
}
