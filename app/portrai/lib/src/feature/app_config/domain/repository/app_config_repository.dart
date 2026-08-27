import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';

abstract class AppConfigRepository {
  Future<PortraiAppConfig> getAppConfig();

  Future<void> cacheAppConfig(PortraiAppConfig appConfig);
}
