import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';

@registerSingleton
class AiImageSettingsCache extends KeyValueCache<AiImageSettings> {
  AiImageSettingsCache() : super('ai_image_settings_cache');

  @override
  AiImageSettings deserializeValue(Map<String, dynamic> map) => AiImageSettings(
    style: AiImageStyle.values.asNameMap()[map['style']] ?? AiImageStyle.avatar,
    model:
        AiImageModelType.values.asNameMap()[map['model']] ??
        AiImageModelType.geminiFlashImage,
  );

  @override
  Map<String, dynamic> serializeValue(AiImageSettings value) => {
    'style': value.style.name,
    'model': value.model.name,
  };
}
