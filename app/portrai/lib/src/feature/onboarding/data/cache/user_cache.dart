import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/onboarding/data/model/_model.dart';

@registerSingleton
class UserCache extends KeyValueCache<UserModel> {
  UserCache() : super('user_cache');

  @override
  UserModel deserializeValue(Map<String, dynamic> map) {
    return UserModel.fromJson(map);
  }

  @override
  Map<String, dynamic> serializeValue(UserModel value) => value.toJson();
}
