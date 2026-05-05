import 'dart:async';

import 'package:module_injector/src/configurator/module_configurator.dart';
import 'package:module_injector/src/service_locator/service_locator.dart';

/// A [ModuleConfigurator] with default no-op [preDependenciesSetup] and
/// [postDependenciesSetup] implementations.
///
/// Extend this class when your module only needs to register dependencies
/// without any pre/post lifecycle hooks, eliminating empty method stubs.
///
/// ### Example
///
/// ```dart
/// class ProfileModuleConfigurator extends SimpleModuleConfigurator {
///   @override
///   void registerDependencies(ServiceLocator sl) {
///     sl.registerFactory(() => ProfileRepository());
///     sl.registerFactory(() => GetProfileUseCase(sl.get()));
///   }
/// }
/// ```
abstract class SimpleModuleConfigurator implements ModuleConfigurator {
  const SimpleModuleConfigurator();

  @override
  FutureOr<void> preDependenciesSetup(ServiceLocator serviceLocator) {}

  @override
  FutureOr<void> postDependenciesSetup(ServiceLocator serviceLocator) {}
}
