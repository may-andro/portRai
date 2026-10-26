import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/connectivity/connectivity_module_configurator.di.g.dart';
import 'package:portrai/src/feature/connectivity/data/_data.dart';
import 'package:portrai/src/feature/connectivity/domain/_domain.dart';

@generateConfigurator
class ConnectivityModuleConfigurator extends SimpleModuleConfigurator {
  /// Builds the use case without the dependency graph, for code that runs
  /// before the graph is set up.
  static CheckInternetConnectionUseCase
  createCheckInternetConnectionUseCase() => CheckInternetConnectionUseCase(
    ConnectivityPlusRepositoryImpl.standalone(),
  );

  @override
  void registerDependencies(ServiceLocator sl) {
    $registerConnectivityDependencies(sl);
  }
}
