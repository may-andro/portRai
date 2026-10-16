import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';

@register
class AiImageAppConfigMapper
    implements BiMapper<AiImageAppConfigModel, AiImageAppConfig> {
  const AiImageAppConfigMapper();

  @override
  AiImageAppConfig to(AiImageAppConfigModel from) =>
      AiImageAppConfig(model: from.model, style: from.style);

  @override
  AiImageAppConfigModel from(AiImageAppConfig to) =>
      AiImageAppConfigModel(model: to.model, style: to.style);
}
