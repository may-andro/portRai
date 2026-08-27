import 'package:core/core.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';
import 'package:use_case/use_case.dart';

@register
class GetMinimumRequiredAppVersionUseCase
    extends BaseNoParamUseCase<String, NoFailure> {
  GetMinimumRequiredAppVersionUseCase(this._appConfig);

  final AppConfig _appConfig;

  @protected
  @override
  Either<NoFailure, String> execute() {
    final appConfig = _appConfig;
    if (appConfig is! PortraiAppConfig) {
      throw StateError(
        'Unexpected AppConfig implementation: ${appConfig.runtimeType}',
      );
    }

    return Right(appConfig.minimumRequiredAppVersion);
  }

  @protected
  @override
  NoFailure mapErrorToFailure(Object e, StackTrace st) => NoFailure();
}
