import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/flutter_edge_ai_local_assistant_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/route/route.dart';

import '../../../mock/feature/feature_flag/domain/registry/mock_app_feature_flag_definition_registry.dart';
import '../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../mock/feature/local_assistant/presentation/screen/local_assistant/bloc/mock_local_assistant_bloc.dart';
import '../../../mock/utility/mock_module_route_controller.dart';
import '../../../mock/utility/mock_service_locator.dart';

void main() {
  test(
    'should separate registrations when both assistant modules register',
    () async {
      final locator = ModuleInjectorController().serviceLocator;
      await locator.reset();
      addTearDown(locator.reset);
      locator.registerFactory<IsFeatureEnabledUseCase>(
        () => MockIsFeatureEnabledUseCase(),
      );

      AssistantModuleConfigurator().registerDependencies(locator);

      expect(locator.isRegistered<GetAssistantContextUseCase>(), isTrue);
      expect(locator.isRegistered<LocalAssistantRepository>(), isFalse);
      expect(locator.isRegistered<LocalAssistantBloc>(), isFalse);

      LocalAssistantModuleConfigurator().registerDependencies(locator);

      expect(locator.isRegistered<GetAssistantContextUseCase>(), isTrue);
      expect(locator.isRegistered<LocalAssistantRepository>(), isTrue);
      expect(locator.isRegistered<PrepareLocalAssistantModelUseCase>(), isTrue);
      expect(locator.isRegistered<LocalAssistantBloc>(), isTrue);
      expect(
        locator.get<LocalAssistantRepository>(),
        isA<FlutterEdgeAiLocalAssistantRepository>(),
      );
    },
  );

  test(
    'should preserve the route and rollout key when local post setup runs',
    () async {
      final locator = MockServiceLocator();
      final registry = MockAppFeatureFlagDefinitionRegistry();
      final routes = MockModuleRouteController();
      final bloc = MockLocalAssistantBloc();
      addTearDown(bloc.close);
      when(
        () => locator.get<AppFeatureFlagDefinitionRegistry>(),
      ).thenReturn(registry);
      when(() => locator.get<ModuleRouteController>()).thenReturn(routes);
      when(() => locator.get<LocalAssistantBloc>()).thenReturn(bloc);

      await LocalAssistantModuleConfigurator().postDependenciesSetup(locator);

      expect(
        LocalAssistantFeatureFlags.aiAssistant.key,
        'feature_ai_assistant',
      );
      expect(LocalAssistantFeatureFlags.aiAssistant.defaultValue, isFalse);
      expect(LocalAssistantModuleRoute.assistant.name, 'assistant');
      expect(LocalAssistantModuleRoute.assistant.path, '/assistant');
      verify(
        () => registry.register(LocalAssistantFeatureFlags.aiAssistant),
      ).called(1);
      if (isLocalAssistantSupported) {
        verify(
          () => routes.register(LocalAssistantModuleRoute.assistant),
        ).called(1);
        verify(
          () => bloc.add(const LocalAssistantInitializedEvent()),
        ).called(1);
      } else {
        verifyNever(() => routes.register(LocalAssistantModuleRoute.assistant));
        verifyNever(() => bloc.add(const LocalAssistantInitializedEvent()));
      }
    },
  );
}
