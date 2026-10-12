import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/asset_source/asset_source_module_configurator.di.g.dart';

@generateConfigurator
class AssetSourceModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerAssetSourceDependencies(sl);
}
