import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';

class AppLocaleConfigurator implements ModuleConfigurator {
  AppLocaleConfigurator(this._appLocale);

  final AppLocale _appLocale;

  @override
  void postDependenciesSetup(ServiceLocator serviceLocator) {}

  @override
  void preDependenciesSetup(ServiceLocator serviceLocator) {}

  @override
  void registerDependencies(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton<AppLocale>(() => _appLocale);
  }
}
