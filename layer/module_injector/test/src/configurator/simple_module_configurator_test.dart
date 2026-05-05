import 'package:flutter_test/flutter_test.dart';
import 'package:module_injector/src/configurator/simple_module_configurator.dart';
import 'package:module_injector/src/service_locator/service_locator.dart';

class _TestSimpleConfigurator extends SimpleModuleConfigurator {
  bool registerDependenciesCalled = false;

  @override
  void registerDependencies(ServiceLocator serviceLocator) {
    registerDependenciesCalled = true;
  }
}

class _FakeServiceLocator extends Fake implements ServiceLocator {}

void main() {
  group(SimpleModuleConfigurator, () {
    late _TestSimpleConfigurator configurator;
    late ServiceLocator serviceLocator;

    setUp(() {
      configurator = _TestSimpleConfigurator();
      serviceLocator = _FakeServiceLocator();
    });

    test('preDependenciesSetup is a no-op by default', () async {
      await configurator.preDependenciesSetup(serviceLocator);
      // Should complete without error
    });

    test('postDependenciesSetup is a no-op by default', () async {
      await configurator.postDependenciesSetup(serviceLocator);
      // Should complete without error
    });

    test('registerDependencies must be implemented', () {
      configurator.registerDependencies(serviceLocator);
      expect(configurator.registerDependenciesCalled, isTrue);
    });
  });
}
