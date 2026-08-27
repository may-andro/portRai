import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/app_config/data/cache/app_config_cache.dart';

class MockAppConfigCache extends Mock implements AppConfigCache {}

extension MockAppConfigCacheStub on MockAppConfigCache {
  /// Stubs `get()` to return [appConfig].
  void stubGet(PortraiAppConfig? appConfig) {
    when(get).thenAnswer((_) async => appConfig);
  }

  /// Stubs `get()` to throw [error].
  void stubGetThrows(Object error) {
    when(get).thenThrow(error);
  }

  /// Stubs `put(appConfig)` to complete successfully.
  void stubPut() {
    when(() => put(any())).thenAnswer((_) async => true);
  }

  /// Stubs `put(appConfig)` to throw [error].
  void stubPutThrows(Object error) {
    when(() => put(any())).thenThrow(error);
  }
}
