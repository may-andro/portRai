import 'package:cache/cache.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_rate_limit/data/model/_model.dart';

@registerSingleton
class AiRequestLogCache extends KeyValueCache<AiRequestLogModel> {
  AiRequestLogCache() : super('ai_request_log_cache');

  @override
  AiRequestLogModel deserializeValue(Map<String, dynamic> map) =>
      AiRequestLogModel.fromJson(map);

  @override
  Map<String, dynamic> serializeValue(AiRequestLogModel value) =>
      value.toJson();
}
