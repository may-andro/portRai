import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/data/model/_model.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';

@register
class AiImageMapper {
  const AiImageMapper();

  AiImageEntity toEntity(AiImageModel model) =>
      AiImageEntity(bytes: model.bytes, mimeType: model.mimeType);

  AiImageModel toModel(AiImageEntity entity, {required String key}) =>
      AiImageModel(key: key, mimeType: entity.mimeType, bytes: entity.bytes);
}
