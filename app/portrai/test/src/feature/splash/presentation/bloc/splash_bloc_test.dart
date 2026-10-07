import 'package:bloc_test/bloc_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/splash/presentation/bloc/_bloc.dart';

class _NoOpModuleConfigurator extends ModuleConfigurator {
  @override
  Future<void> preDependenciesSetup(ServiceLocator serviceLocator) =>
      Future.value();

  @override
  Future<void> registerDependencies(ServiceLocator serviceLocator) =>
      Future.value();

  @override
  Future<void> postDependenciesSetup(ServiceLocator serviceLocator) =>
      Future.value();
}

class _ThrowingRegisterModuleConfigurator extends ModuleConfigurator {
  @override
  Future<void> preDependenciesSetup(ServiceLocator serviceLocator) =>
      Future.value();

  @override
  Future<void> registerDependencies(ServiceLocator serviceLocator) =>
      Future.error(
        RegisterInjectionException('register failed', 'bad dependency'),
      );

  @override
  Future<void> postDependenciesSetup(ServiceLocator serviceLocator) =>
      Future.value();
}

void main() {
  group('SplashBloc', () {
    blocTest<SplashBloc, SplashState>(
      'should emit setup progress updates and completion when initialization succeeds',
      build: () =>
          SplashBloc(ModuleInjectorController(), [_NoOpModuleConfigurator()]),
      act: (bloc) => bloc.add(InitEvent()),
      expect: () => const [
        SetUpProgressState([InjectionStatus.start], 0.25),
        SetUpProgressState([
          InjectionStatus.start,
          InjectionStatus.register,
        ], 0.5),
        SetUpProgressState([
          InjectionStatus.start,
          InjectionStatus.register,
          InjectionStatus.postRegister,
        ], 0.75),
        SetUpProgressState(InjectionStatus.values, 1),
        SetUpCompetedState(DesignSystem.hogmanay),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'should emit an error state when initialization throws an injection exception',
      build: () => SplashBloc(ModuleInjectorController(), [
        _ThrowingRegisterModuleConfigurator(),
      ]),
      act: (bloc) => bloc.add(InitEvent()),
      expect: () => const [
        SetUpProgressState([InjectionStatus.start], 0.25),
        SetUpProgressState([
          InjectionStatus.start,
          InjectionStatus.register,
        ], 0.5),
        SetUpErrorState('register failed'),
      ],
    );
  });
}
