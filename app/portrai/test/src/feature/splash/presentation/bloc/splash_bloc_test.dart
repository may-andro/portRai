import 'package:bloc_test/bloc_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/splash/presentation/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/connectivity/domain/use_case/mock_check_internet_connection_use_case.dart';

class _NoOpModuleConfigurator extends ModuleConfigurator {
  @override
  Future<void> preDependenciesSetup(ServiceLocator serviceLocator) =>
      Future.value();

  @override
  Future<void> registerDependencies(ServiceLocator serviceLocator) {
    serviceLocator.registerSingleton<DesignSystem>(() => DesignSystem.hogmanay);
    return Future.value();
  }

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

class _FailingOnceModuleConfigurator extends _NoOpModuleConfigurator {
  bool _hasFailed = false;

  @override
  Future<void> postDependenciesSetup(ServiceLocator serviceLocator) {
    if (_hasFailed) return Future.value();
    _hasFailed = true;
    return Future.error(PostInjectionException('post failed', 'offline'));
  }
}

void main() {
  group('SplashBloc', () {
    late MockCheckInternetConnectionUseCase checkInternetConnectionUseCase;

    setUp(() {
      checkInternetConnectionUseCase = MockCheckInternetConnectionUseCase()
        ..stubCall(const Right(true));
    });

    blocTest<SplashBloc, SplashState>(
      'should emit setup progress updates and completion when initialization succeeds',
      build: () => SplashBloc(ModuleInjectorController(), [
        _NoOpModuleConfigurator(),
      ], checkInternetConnectionUseCase: checkInternetConnectionUseCase),
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
      ], checkInternetConnectionUseCase: checkInternetConnectionUseCase),
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

    blocTest<SplashBloc, SplashState>(
      'should complete without checking the internet when set up succeeds',
      setUp: () => checkInternetConnectionUseCase.stubCall(const Right(false)),
      build: () => SplashBloc(ModuleInjectorController(), [
        _NoOpModuleConfigurator(),
      ], checkInternetConnectionUseCase: checkInternetConnectionUseCase),
      act: (bloc) => bloc.add(InitEvent()),
      skip: 4,
      expect: () => const [SetUpCompetedState(DesignSystem.hogmanay)],
      verify: (_) => verifyNever(checkInternetConnectionUseCase.call),
    );

    blocTest<SplashBloc, SplashState>(
      'should emit no internet state when set up fails without internet',
      setUp: () => checkInternetConnectionUseCase.stubCall(const Right(false)),
      build: () => SplashBloc(ModuleInjectorController(), [
        _ThrowingRegisterModuleConfigurator(),
      ], checkInternetConnectionUseCase: checkInternetConnectionUseCase),
      act: (bloc) => bloc.add(InitEvent()),
      expect: () => const [
        SetUpProgressState([InjectionStatus.start], 0.25),
        SetUpProgressState([
          InjectionStatus.start,
          InjectionStatus.register,
        ], 0.5),
        SetUpNoInternetState(),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'should complete when retry is clicked after set up failed without '
      'internet',
      build: () => SplashBloc(ModuleInjectorController(), [
        _FailingOnceModuleConfigurator(),
      ], checkInternetConnectionUseCase: checkInternetConnectionUseCase),
      act: (bloc) async {
        checkInternetConnectionUseCase.stubCall(const Right(false));
        bloc.add(InitEvent());
        await pumpEventQueue();
        checkInternetConnectionUseCase.stubCall(const Right(true));
        bloc.add(RetryClickEvent());
      },
      skip: 3,
      expect: () => const [
        SetUpNoInternetState(),
        SetUpProgressState([], 0),
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
      'should initialize when retry is clicked and internet is back',
      setUp: () => checkInternetConnectionUseCase.stubCall(const Right(true)),
      build: () => SplashBloc(ModuleInjectorController(), [
        _NoOpModuleConfigurator(),
      ], checkInternetConnectionUseCase: checkInternetConnectionUseCase),
      seed: () => const SetUpNoInternetState(),
      act: (bloc) => bloc.add(RetryClickEvent()),
      expect: () => const [
        SetUpProgressState([], 0),
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
  });
}
