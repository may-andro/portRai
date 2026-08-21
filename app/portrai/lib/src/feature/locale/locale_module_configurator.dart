import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/locale_module_configurator.di.g.dart';
import 'package:portrai/src/feature/locale/presentation/_presentation.dart';
import 'package:portrai/src/route/core/module_route_controller.dart';

@generateConfigurator
class LocaleModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerLocaleDependencies(sl);
  }

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    final appLocale = sl.get<AppLocale>();
    final appLocaleEither = await sl.get<GetLocaleUseCase>().call();

    if (appLocaleEither.isRight) {
      final cachedAppLocale = appLocaleEither.right;
      if (appLocale != cachedAppLocale) {
        sl.get<UpdateLocaleUseCase>().call(cachedAppLocale);
      }
    }

    sl.get<ModuleRouteController>().register(LocaleModuleRoute.localeSelection);
  }
}
