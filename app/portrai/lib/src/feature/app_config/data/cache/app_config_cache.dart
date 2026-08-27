import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';

@registerSingleton
class AppConfigCache extends KeyValueCache<PortraiAppConfigEntity> {
  AppConfigCache() : super('app_config_cache');

  @override
  PortraiAppConfigEntity deserializeValue(Map<String, dynamic> map) {
    return PortraiAppConfigEntity.fromJson(map);
  }

  @override
  Map<String, dynamic> serializeValue(PortraiAppConfigEntity value) {
    return value.toJson();
  }
}
