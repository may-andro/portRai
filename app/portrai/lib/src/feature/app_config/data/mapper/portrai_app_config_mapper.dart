import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/data/mapper/ai_image_app_config_mapper.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';

@register
class PortraiAppConfigMapper
    implements BiMapper<PortraiAppConfigModel, PortraiAppConfigEntity> {
  const PortraiAppConfigMapper(this._aiImageMapper);

  final AiImageAppConfigMapper _aiImageMapper;

  @override
  PortraiAppConfigEntity to(PortraiAppConfigModel from) {
    final aiImage = from.aiImage;
    return PortraiAppConfigEntity(
      minimumRequiredAppVersion: from.minimumRequiredAppVersion,
      aiImage: aiImage == null
          ? const AiImageAppConfig()
          : _aiImageMapper.to(aiImage),
    );
  }

  @override
  PortraiAppConfigModel from(PortraiAppConfigEntity to) =>
      PortraiAppConfigModel(
        minimumRequiredAppVersion: to.minimumRequiredAppVersion,
        aiImage: _aiImageMapper.from(to.aiImage),
      );
}
