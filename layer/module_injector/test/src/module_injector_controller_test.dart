import 'package:flutter_test/flutter_test.dart';
import 'package:module_injector/src/configurator/module_configurator.dart';
import 'package:module_injector/src/model/injection_status.dart';
import 'package:module_injector/src/module_injector_controller.dart';
import 'package:module_injector/src/service_locator/get_it_service_locator.dart';
import 'package:module_injector/src/service_locator/service_locator.dart';

class MockModuleConfigurator extends ModuleConfigurator {
  bool preDependenciesSetupCalled = false;
  bool registerDependenciesCalled = false;
  bool postDependenciesSetupCalled = false;

  @override
  Future<void> preDependenciesSetup(ServiceLocator serviceLocator) async {
    preDependenciesSetupCalled = true;
  }

  @override
  Future<void> registerDependencies(ServiceLocator serviceLocator) async {
    registerDependenciesCalled = true;
  }

  @override
  Future<void> postDependenciesSetup(ServiceLocator serviceLocator) async {
    postDependenciesSetupCalled = true;
  }
}

void main() {
  group(ModuleInjectorController, () {
    late ModuleInjectorController controller;
    late MockModuleConfigurator mockConfigurator;

    setUp(() {
      controller = ModuleInjectorController();
      mockConfigurator = MockModuleConfigurator();
    });

    group('serviceLocator', () {
      test('should initializes with default GetItServiceLocator', () {
        expect(controller.serviceLocator, isA<GetItServiceLocator>());
      });
    });

    group('setUpDIGraph', () {
      test(
        'should calls preDependenciesSetup, registerDependencies, and postDependenciesSetup',
        () async {
          final statuses = <InjectionStatus>[];
          final stream = controller.setUpDIGraph(
            configurators: [mockConfigurator],
          );

          await for (final status in stream) {
            statuses.add(status);
          }

          expect(statuses, [
            InjectionStatus.start,
            InjectionStatus.register,
            InjectionStatus.postRegister,
            InjectionStatus.finished,
          ]);
          expect(mockConfigurator.preDependenciesSetupCalled, isTrue);
          expect(mockConfigurator.registerDependenciesCalled, isTrue);
          expect(mockConfigurator.postDependenciesSetupCalled, isTrue);
        },
      );

      test('should emits correct InjectionStatus values', () async {
        final statuses = <InjectionStatus>[];
        final stream = controller.setUpDIGraph(
          configurators: [mockConfigurator],
        );

        await for (final status in stream) {
          statuses.add(status);
        }

        expect(statuses, [
          InjectionStatus.start,
          InjectionStatus.register,
          InjectionStatus.postRegister,
          InjectionStatus.finished,
        ]);
      });
    });
  });
}
