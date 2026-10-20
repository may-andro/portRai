import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/user/data/model/_model.dart';

@registerSingleton
class GuestUserCache extends KeyValueCache<GuestUserModel> {
  // Changing this key would lose the roles already saved on devices.
  GuestUserCache() : super('user_cache');

  @override
  GuestUserModel deserializeValue(Map<String, dynamic> map) {
    return GuestUserModel.fromJson(map);
  }

  @override
  Map<String, dynamic> serializeValue(GuestUserModel value) => value.toJson();
}
