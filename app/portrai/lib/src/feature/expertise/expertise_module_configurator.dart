import 'package:module_injector/module_injector.dart';

// ignore: unused_import — needed by code generator to discover @register classes
import 'package:portrai/src/feature/expertise/data/_data.dart';

// ignore: unused_import — needed by code generator to discover @register classes
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

import 'package:portrai/src/feature/expertise/expertise_module_configurator.di.g.dart';

@generateConfigurator
class ExpertiseModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) {
    $registerExpertiseDependencies(sl);
  }
}
