import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';

abstract class AppConfigRepository {
  Future<PortraiAppConfigEntity> getAppConfig();

  Future<void> cacheAppConfig(PortraiAppConfigEntity appConfig);
}
