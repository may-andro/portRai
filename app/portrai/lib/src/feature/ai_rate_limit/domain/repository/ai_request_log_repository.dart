import 'package:portrai/src/feature/ai_rate_limit/domain/entity/_entity.dart';

abstract class AiRequestLogRepository {
  Future<AiRequestLogEntity> getAiRequestLog();

  Future<void> cacheAiRequestLog(AiRequestLogEntity aiRequestLog);
}
