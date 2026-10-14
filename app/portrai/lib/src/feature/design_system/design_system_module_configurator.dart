import 'package:design_system/design_system.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/design_system/design_system_module_configurator.di.g.dart';
import 'package:portrai/src/feature/design_system/domain/use_case/_use_case.dart';

@generateConfigurator
class DesignSystemModuleConfigurator extends SimpleModuleConfigurator {
  @override
  Future<void> postDependenciesSetup(ServiceLocator serviceLocator) async {
    final cachedDesignSystemEither = await serviceLocator
        .get<GetDesignSystemUseCase>()
        .call();
    final designSystem =
        cachedDesignSystemEither.right ??
        (await serviceLocator.get<SelectDesignSystemUseCase>().call()).right;
    serviceLocator.registerSingleton<DesignSystem>(() => designSystem);
  }

  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerDesignSystemDependencies(sl);
}
