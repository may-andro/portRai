import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';

@registerSingleton
class LocalAssistantEnabledCache extends KeyValueCache<bool> {
  LocalAssistantEnabledCache() : super('assistant_enabled_cache');

  @override
  bool deserializeValue(Map<String, dynamic> map) => map['enabled'] == true;

  @override
  Map<String, dynamic> serializeValue(bool value) => {'enabled': value};
}
