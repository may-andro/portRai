import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/ai_rate_limit/data/model/_model.dart';
import 'package:portrai/src/feature/ai_rate_limit/domain/entity/_entity.dart';

@register
class AiRequestLogMapper
    implements BiMapper<AiRequestLogModel, AiRequestLogEntity> {
  const AiRequestLogMapper();

  @override
  AiRequestLogEntity to(AiRequestLogModel from) => AiRequestLogEntity(
    requestTimes: [
      for (final milliseconds in from.requestTimesInMilliseconds)
        DateTime.fromMillisecondsSinceEpoch(milliseconds),
    ],
  );

  @override
  AiRequestLogModel from(AiRequestLogEntity to) => AiRequestLogModel(
    requestTimesInMilliseconds: [
      for (final requestTime in to.requestTimes)
        requestTime.millisecondsSinceEpoch,
    ],
  );
}
