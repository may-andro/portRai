import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/remote_assistant/domain/entity/remote_assistant_preference_entity.dart';

@registerSingleton
class RemoteAssistantPreferenceCache
    extends KeyValueCache<RemoteAssistantPreferenceEntity> {
  RemoteAssistantPreferenceCache() : super(cacheKey);

  static const cacheKey = 'remote_assistant_preference_cache';
  static const consentVersion = 1;

  @override
  RemoteAssistantPreferenceEntity deserializeValue(Map<String, dynamic> map) {
    final consentAccepted =
        map['consentVersion'] == consentVersion &&
        map['consentAccepted'] == true;
    return RemoteAssistantPreferenceEntity(
      enabled: consentAccepted && map['enabled'] == true,
      consentAccepted: consentAccepted,
    );
  }

  @override
  Map<String, dynamic> serializeValue(RemoteAssistantPreferenceEntity value) {
    final consentAccepted = value.consentAccepted;
    return {
      'consentVersion': consentVersion,
      'consentAccepted': consentAccepted,
      'enabled': consentAccepted && value.enabled,
    };
  }
}
