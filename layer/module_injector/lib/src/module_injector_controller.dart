import 'package:module_injector/src/configurator/module_configurator.dart';
import 'package:module_injector/src/model/injection_status.dart';
import 'package:module_injector/src/service_locator/get_it_service_locator.dart';
import 'package:module_injector/src/service_locator/service_locator.dart';

class ModuleInjectorController {
  factory ModuleInjectorController() {
    return ModuleInjectorController._internal(const GetItServiceLocator());
  }

  ModuleInjectorController._internal(this._serviceLocator);

  final ServiceLocator _serviceLocator;

  ServiceLocator get serviceLocator => _serviceLocator;

  Stream<InjectionStatus> setUpDIGraph({
    required List<ModuleConfigurator> configurators,
  }) async* {
    await _serviceLocator.reset();

    yield InjectionStatus.start;

    for (final configurator in configurators) {
      await configurator.preDependenciesSetup(_serviceLocator);
    }

    yield InjectionStatus.register;

    for (final configurator in configurators) {
      await configurator.registerDependencies(_serviceLocator);
    }

    yield InjectionStatus.postRegister;

    for (final configurator in configurators) {
      await configurator.postDependenciesSetup(_serviceLocator);
    }

    yield InjectionStatus.finished;
  }
}
