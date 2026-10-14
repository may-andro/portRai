import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';

import '../../../mock/feature/design_system/domain/use_case/mock_get_design_system_use_case.dart';
import '../../../mock/feature/design_system/domain/use_case/mock_select_design_system_use_case.dart';

void main() {
  group('DesignSystemModuleConfigurator', () {
    late ServiceLocator serviceLocator;
    late MockGetDesignSystemUseCase getDesignSystemUseCase;
    late MockSelectDesignSystemUseCase selectDesignSystemUseCase;

    setUp(() async {
      serviceLocator = ModuleInjectorController().serviceLocator;
      await serviceLocator.reset();
      addTearDown(serviceLocator.reset);
      getDesignSystemUseCase = MockGetDesignSystemUseCase();
      selectDesignSystemUseCase = MockSelectDesignSystemUseCase()
        ..stubCall(DesignSystem.halloween);
      serviceLocator.registerSingleton<GetDesignSystemUseCase>(
        () => getDesignSystemUseCase,
      );
      serviceLocator.registerSingleton<SelectDesignSystemUseCase>(
        () => selectDesignSystemUseCase,
      );
    });

    test(
      'should register the cached design system when one is stored',
      () async {
        getDesignSystemUseCase.stubCall(DesignSystem.holi);

        await DesignSystemModuleConfigurator().postDependenciesSetup(
          serviceLocator,
        );

        expect(serviceLocator.get<DesignSystem>(), DesignSystem.holi);
        verify(() => getDesignSystemUseCase()).called(1);
        verifyNever(() => selectDesignSystemUseCase());
      },
    );

    test(
      'should register the monthly design system when no design system is stored',
      () async {
        getDesignSystemUseCase.stubCall(null);

        await DesignSystemModuleConfigurator().postDependenciesSetup(
          serviceLocator,
        );

        expect(serviceLocator.get<DesignSystem>(), DesignSystem.halloween);
        verify(() => getDesignSystemUseCase()).called(1);
        verify(() => selectDesignSystemUseCase()).called(1);
      },
    );
  });
}
