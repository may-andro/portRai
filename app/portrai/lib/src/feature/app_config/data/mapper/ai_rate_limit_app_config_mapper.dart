import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';

@register
class AiRateLimitAppConfigMapper
    implements BiMapper<AiRateLimitAppConfigModel, AiRateLimitAppConfig> {
  const AiRateLimitAppConfigMapper();

  @override
  AiRateLimitAppConfig to(AiRateLimitAppConfigModel from) =>
      AiRateLimitAppConfig(
        maxRequestsPerMinute: from.maxRequestsPerMinute,
        maxRequestsPerDay: from.maxRequestsPerDay,
      );

  @override
  AiRateLimitAppConfigModel from(AiRateLimitAppConfig to) =>
      AiRateLimitAppConfigModel(
        maxRequestsPerMinute: to.maxRequestsPerMinute,
        maxRequestsPerDay: to.maxRequestsPerDay,
      );
}
