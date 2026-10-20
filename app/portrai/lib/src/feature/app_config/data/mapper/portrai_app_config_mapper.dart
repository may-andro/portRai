import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/data/mapper/ai_image_app_config_mapper.dart';
import 'package:portrai/src/feature/app_config/data/mapper/ai_rate_limit_app_config_mapper.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';

@register
class PortraiAppConfigMapper
    implements BiMapper<PortraiAppConfigModel, PortraiAppConfigEntity> {
  const PortraiAppConfigMapper(this._aiImageMapper, this._aiRateLimitMapper);

  final AiImageAppConfigMapper _aiImageMapper;
  final AiRateLimitAppConfigMapper _aiRateLimitMapper;

  @override
  PortraiAppConfigEntity to(PortraiAppConfigModel from) {
    final aiImage = from.aiImage;
    final aiRateLimit = from.aiRateLimit;
    return PortraiAppConfigEntity(
      minimumRequiredAppVersion: from.minimumRequiredAppVersion,
      aiImage: aiImage == null
          ? const AiImageAppConfig()
          : _aiImageMapper.to(aiImage),
      aiAssistantModel: from.aiAssistantModel,
      aiRateLimit: aiRateLimit == null
          ? const AiRateLimitAppConfig()
          : _aiRateLimitMapper.to(aiRateLimit),
    );
  }

  @override
  PortraiAppConfigModel from(PortraiAppConfigEntity to) =>
      PortraiAppConfigModel(
        minimumRequiredAppVersion: to.minimumRequiredAppVersion,
        aiImage: _aiImageMapper.from(to.aiImage),
        aiAssistantModel: to.aiAssistantModel,
        aiRateLimit: _aiRateLimitMapper.from(to.aiRateLimit),
      );
}
