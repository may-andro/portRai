import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_image_gen/data/cache/_cache.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/entity/_entity.dart';
import 'package:portrai/src/feature/ai_image_gen/domain/repository/_repository.dart';

@Register(as: AiImageSettingsRepository)
class AiImageSettingsRepositoryImpl implements AiImageSettingsRepository {
  AiImageSettingsRepositoryImpl(this._cache);

  final AiImageSettingsCache _cache;

  @override
  Future<AiImageSettings?> getSettings() => _cache.get();

  @override
  Future<void> setSettings(AiImageSettings settings) async {
    await _cache.put(settings);
  }
}
