import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';
import 'package:portrai/src/feature/onboarding/onboarding_module_configurator.di.g.dart';
import 'package:portrai/src/feature/onboarding/presentation/_presentation.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';
import 'package:portrai/src/route/route.dart';

@generateConfigurator
class OnboardingModuleConfigurator extends SimpleModuleConfigurator {
  @override
  void registerDependencies(ServiceLocator sl) =>
      $registerOnboardingDependencies(sl);

  @override
  Future<void> postDependenciesSetup(ServiceLocator sl) async {
    final registry = sl.get<AppFeatureFlagDefinitionRegistry>();
    for (final definition in OnboardingFeatureFlags.all) {
      registry.register(definition);
    }

    final routeController = sl.get<ModuleRouteController>()
      ..register(OnboardingModuleRoute.onboarding);

    final shouldShowOnboardingUseCase = sl.get<ShouldShowOnboardingUseCase>();
    routeController.registerRedirect((context, requestedUri) async {
      if (requestedUri.path != PortfolioModuleRoute.portfolio.path) return null;
      final shouldShowEither = await shouldShowOnboardingUseCase();
      return shouldShowEither.isRight && shouldShowEither.right
          ? OnboardingModuleRoute.onboarding.path
          : null;
    });
  }
}
