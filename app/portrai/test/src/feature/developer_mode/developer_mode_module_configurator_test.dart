import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/developer_mode_module_configurator.dart';
import 'package:portrai/src/feature/developer_mode/presentation/route/developer_menu_module_route.dart';
import 'package:portrai/src/route/route.dart';

import '../../../mock/utility/mock_module_route_controller.dart';
import '../../../mock/utility/mock_service_locator.dart';

void main() {
  group('DeveloperModeModuleConfigurator', () {
    late MockServiceLocator serviceLocator;
    late MockModuleRouteController routeController;
    late DeveloperModeModuleConfigurator configurator;

    setUp(() {
      serviceLocator = MockServiceLocator();
      routeController = MockModuleRouteController();
      configurator = DeveloperModeModuleConfigurator();
      when(
        () => serviceLocator.get<BuildConfig>(),
      ).thenReturn(BuildConfig(buildEnvironment: BuildEnvironment.staging));

      when(
        () => serviceLocator.get<ModuleRouteController>(),
      ).thenReturn(routeController);
      when(
        () => routeController.register(DeveloperMenuModuleRoute.developerMenu),
      ).thenReturn(null);
    });

    test('should register the developer menu route when post setup runs', () {
      configurator.postDependenciesSetup(serviceLocator);

      verify(
        () => routeController.register(DeveloperMenuModuleRoute.developerMenu),
      ).called(1);
    });

    test('should not register the developer menu route when in production', () {
      when(
        () => serviceLocator.get<BuildConfig>(),
      ).thenReturn(BuildConfig(buildEnvironment: BuildEnvironment.prod));

      configurator.postDependenciesSetup(serviceLocator);

      verifyNever(
        () => routeController.register(DeveloperMenuModuleRoute.developerMenu),
      );
    });
  });
}
