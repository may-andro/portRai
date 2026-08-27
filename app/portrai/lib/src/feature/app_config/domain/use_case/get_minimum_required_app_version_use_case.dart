import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';

@register
class GetMinimumRequiredAppVersionUseCase {
  GetMinimumRequiredAppVersionUseCase(this._appConfig);

  final AppConfig _appConfig;

  String call() {
    final appConfig = _appConfig;
    if (appConfig is! PortraiAppConfig) {
      throw StateError(
        'Unexpected AppConfig implementation: ${appConfig.runtimeType}',
      );
    }

    return appConfig.minimumRequiredAppVersion;
  }
}
