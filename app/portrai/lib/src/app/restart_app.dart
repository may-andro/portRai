import 'package:design_system/design_system.dart';
import 'package:portrai/src/app/run_app_initialization.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

Future<void> restartApp() async {
  await appServiceLocator.reset();
  await runAppWithInitialization();
}

void restartAppWithoutInitialization() {
  runMainApp(DesignSystem.beltane);
}
