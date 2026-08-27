import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/app_config/domain/repository/app_config_repository.dart';

class MockAppConfigRepository extends Mock implements AppConfigRepository {}

extension MockAppConfigRepositoryStub on MockAppConfigRepository {
  /// Stubs `getAppConfig()` to return [appConfig].
  void stubGetAppConfig(PortraiAppConfigEntity appConfig) {
    when(getAppConfig).thenAnswer((_) async => appConfig);
  }

  /// Stubs `getAppConfig()` to throw [error].
  void stubGetAppConfigThrows(Object error) {
    when(getAppConfig).thenThrow(error);
  }

  /// Stubs `cacheAppConfig(appConfig)` to complete successfully.
  void stubCacheAppConfig() {
    when(() => cacheAppConfig(any())).thenAnswer((_) async {});
  }

  /// Stubs `cacheAppConfig(appConfig)` to throw [error].
  void stubCacheAppConfigThrows(Object error) {
    when(() => cacheAppConfig(any())).thenThrow(error);
  }
}
