import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/route/route.dart';

import '../../../mock/feature/feature_flag/domain/registry/mock_app_feature_flag_definition_registry.dart';
import '../../../mock/utility/mock_module_route_controller.dart';
import '../../../mock/utility/mock_service_locator.dart';

void main() {
  test(
    'should keep remote registrations independent when modules register',
    () async {
      final locator = ModuleInjectorController().serviceLocator;
      await locator.reset();
      addTearDown(locator.reset);
      AssistantModuleConfigurator().registerDependencies(locator);
      expect(locator.isRegistered<RemoteAssistantRepository>(), isFalse);
      RemoteAssistantModuleConfigurator().registerDependencies(locator);
      expect(locator.isRegistered<RemoteAssistantRepository>(), isTrue);
      expect(locator.isRegistered<RemoteAssistantBloc>(), isTrue);
      expect(locator.isRegistered<GetAssistantContextUseCase>(), isTrue);
    },
  );

  test(
    'should register a separate default-off flag when post setup runs',
    () async {
      final locator = MockServiceLocator();
      final registry = MockAppFeatureFlagDefinitionRegistry();
      final routes = MockModuleRouteController();
      when(
        () => locator.get<AppFeatureFlagDefinitionRegistry>(),
      ).thenReturn(registry);
      when(() => locator.get<ModuleRouteController>()).thenReturn(routes);

      await RemoteAssistantModuleConfigurator().postDependenciesSetup(locator);

      expect(RemoteAssistantFeatureFlags.remoteAssistant.defaultValue, isFalse);
      expect(
        RemoteAssistantFeatureFlags.remoteAssistant.key,
        'feature_remote_assistant',
      );
      expect(RemoteAssistantModuleRoute.assistant.path, '/remote-assistant');
      expect(RemoteAssistantModuleRoute.assistant.name, 'remote_assistant');
      verify(
        () => registry.register(RemoteAssistantFeatureFlags.remoteAssistant),
      ).called(1);
      verify(
        () => routes.register(RemoteAssistantModuleRoute.assistant),
      ).called(1);
    },
  );
}
