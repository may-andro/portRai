import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';

@registerSingleton
class AppConfigCache extends KeyValueCache<PortraiAppConfigModel> {
  AppConfigCache() : super('app_config_cache');

  @override
  PortraiAppConfigModel deserializeValue(Map<String, dynamic> map) {
    return PortraiAppConfigModel.fromJson(map);
  }

  @override
  Map<String, dynamic> serializeValue(PortraiAppConfigModel value) {
    return value.toJson();
  }
}
