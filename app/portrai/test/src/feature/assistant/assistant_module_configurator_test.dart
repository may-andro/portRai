import 'package:flutter_test/flutter_test.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/project/project.dart';
import 'package:use_case/use_case.dart';

import '../../../mock/feature/project/domain/use_case/mock_get_projects_use_case.dart';

void main() {
  test(
    'should resolve projects through DI when the assistant module registers',
    () async {
      final locator = ModuleInjectorController().serviceLocator;
      await locator.reset();
      addTearDown(locator.reset);
      locator.registerFactory<GetProjectsUseCase>(
        () => MockGetProjectsUseCase()..stubCall(const Right([])),
      );
      AssistantModuleConfigurator().registerDependencies(locator);

      final result = await locator.get<ResolveAssistantProjectsUseCase>()([
        'id',
      ]);

      expect(result.left, isA<AssistantProjectUnknownIdFailure>());
    },
  );
}
