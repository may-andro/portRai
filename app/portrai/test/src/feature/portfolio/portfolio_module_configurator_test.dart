import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/portfolio/domain/feature_flag/portfolio_feature_flags.dart';
import 'package:portrai/src/feature/portfolio/portfolio_module_configurator.dart';
import 'package:portrai/src/feature/portfolio/presentation/route/portfolio_module_route.dart';
import 'package:portrai/src/route/route.dart';

import '../../../mock/feature/feature_flag/domain/registry/mock_app_feature_flag_definition_registry.dart';
import '../../../mock/utility/mock_module_route_controller.dart';
import '../../../mock/utility/mock_service_locator.dart';

void main() {
  group('PortfolioModuleConfigurator', () {
    late MockServiceLocator serviceLocator;
    late MockModuleRouteController routeController;
    late MockAppFeatureFlagDefinitionRegistry registry;
    late PortfolioModuleConfigurator configurator;

    setUp(() {
      serviceLocator = MockServiceLocator();
      routeController = MockModuleRouteController();
      registry = MockAppFeatureFlagDefinitionRegistry();
      configurator = PortfolioModuleConfigurator();

      when(
        () => serviceLocator.get<ModuleRouteController>(),
      ).thenReturn(routeController);
      when(
        () => serviceLocator.get<AppFeatureFlagDefinitionRegistry>(),
      ).thenReturn(registry);
      when(
        () => routeController.register(PortfolioModuleRoute.portfolio),
      ).thenReturn(null);
      for (final definition in PortfolioFeatureFlags.all) {
        when(() => registry.register(definition)).thenReturn(null);
      }
    });

    test(
      'should register the route and every feature flag when post setup runs',
      () async {
        await configurator.postDependenciesSetup(serviceLocator);

        verify(
          () => routeController.register(PortfolioModuleRoute.portfolio),
        ).called(1);
        for (final definition in PortfolioFeatureFlags.all) {
          verify(() => registry.register(definition)).called(1);
        }
      },
    );
  });
}
