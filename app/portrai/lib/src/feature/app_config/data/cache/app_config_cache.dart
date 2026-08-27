import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';

@registerSingleton
class AppConfigCache extends KeyValueCache<PortraiAppConfig> {
  AppConfigCache() : super('app_config_cache');

  @override
  PortraiAppConfig deserializeValue(Map<String, dynamic> map) {
    return PortraiAppConfig.fromJson(map);
  }

  @override
  Map<String, dynamic> serializeValue(PortraiAppConfig value) {
    return value.toJson();
  }
}
