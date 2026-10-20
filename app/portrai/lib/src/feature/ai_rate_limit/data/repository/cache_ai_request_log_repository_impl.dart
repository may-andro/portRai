import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_rate_limit/data/cache/_cache.dart';
import 'package:portrai/src/feature/ai_rate_limit/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/_domain.dart';

@Register(as: AiRequestLogRepository)
class CacheAiRequestLogRepositoryImpl implements AiRequestLogRepository {
  CacheAiRequestLogRepositoryImpl(this._aiRequestLogCache, this._mapper);

  final AiRequestLogCache _aiRequestLogCache;
  final AiRequestLogMapper _mapper;

  @override
  Future<AiRequestLogEntity> getAiRequestLog() async {
    try {
      final cachedAiRequestLog = await _aiRequestLogCache.get();
      return cachedAiRequestLog == null
          ? const AiRequestLogEntity()
          : _mapper.to(cachedAiRequestLog);
    } catch (error, stackTrace) {
      throw AiRequestLogCacheException(cause: error, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> cacheAiRequestLog(AiRequestLogEntity aiRequestLog) async {
    try {
      await _aiRequestLogCache.put(_mapper.from(aiRequestLog));
    } catch (error, stackTrace) {
      throw AiRequestLogCacheException(cause: error, stackTrace: stackTrace);
    }
  }
}
