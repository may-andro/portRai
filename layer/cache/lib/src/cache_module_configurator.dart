import 'dart:async';

import 'package:module_injector/module_injector.dart';

class CacheModuleConfigurator implements ModuleConfigurator {
  const CacheModuleConfigurator();

  @override
  FutureOr<void> postDependenciesSetup(ServiceLocator serviceLocator) => null;

  @override
  FutureOr<void> preDependenciesSetup(ServiceLocator serviceLocator) => null;

  @override
  FutureOr<void> registerDependencies(ServiceLocator serviceLocator) {}
}
