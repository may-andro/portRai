import 'package:design_system/design_system.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/design_system/design_system_module_configurator.di.g.dart';
import 'package:portrai/src/feature/design_system/domain/use_case/_use_case.dart';
import 'package:portrai/src/feature/design_system/presentation/route/_route.dart';
import 'package:portrai/src/route/route.dart';

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
    serviceLocator.get<ModuleRouteController>().register(
      DesignSystemModuleRoute.designSystemGallery,
    );
  }

  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerDesignSystemDependencies(sl);
}
