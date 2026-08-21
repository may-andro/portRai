import 'package:module_injector/module_injector.dart';

ServiceLocator get appServiceLocator {
  return ModuleInjectorController().serviceLocator;
}
