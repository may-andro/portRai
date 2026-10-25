import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/notification_module_configurator.di.g.dart';

@generateConfigurator
class NotificationModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerNotificationDependencies(sl);
}
