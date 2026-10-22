import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/portfolio_module_configurator.dart';
import 'package:portrai/src/feature/portfolio/presentation/route/portfolio_module_route.dart';
import 'package:portrai/src/route/route.dart';

import '../../../mock/utility/mock_module_route_controller.dart';
import '../../../mock/utility/mock_service_locator.dart';

void main() {
  group('PortfolioModuleConfigurator', () {
    late MockServiceLocator serviceLocator;
    late MockModuleRouteController routeController;
    late PortfolioModuleConfigurator configurator;

    setUp(() {
      serviceLocator = MockServiceLocator();
      routeController = MockModuleRouteController();
      configurator = PortfolioModuleConfigurator();

      when(
        () => serviceLocator.get<ModuleRouteController>(),
      ).thenReturn(routeController);
      when(
        () => routeController.register(PortfolioModuleRoute.portfolio),
      ).thenReturn(null);
    });

    test('should register the route when post setup runs', () async {
      await configurator.postDependenciesSetup(serviceLocator);

      verify(
        () => routeController.register(PortfolioModuleRoute.portfolio),
      ).called(1);
    });
  });
}
