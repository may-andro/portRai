import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/onboarding/onboarding.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';
import 'package:portrai/src/route/route.dart';
import 'package:use_case/use_case.dart';

import '../../../mock/feature/feature_flag/domain/registry/mock_app_feature_flag_definition_registry.dart';
import '../../../mock/feature/onboarding/domain/use_case/mock_should_show_onboarding_use_case.dart';
import '../../../mock/utility/mock_module_route_controller.dart';
import '../../../mock/utility/mock_service_locator.dart';

void main() {
  setUpAll(() => registerFallbackValue(_noRedirect));

  group('OnboardingModuleConfigurator', () {
    late MockServiceLocator serviceLocator;
    late MockModuleRouteController routeController;
    late MockAppFeatureFlagDefinitionRegistry registry;
    late MockShouldShowOnboardingUseCase shouldShowOnboardingUseCase;
    late ModuleRouteRedirect redirect;

    setUp(() async {
      serviceLocator = MockServiceLocator();
      routeController = MockModuleRouteController();
      registry = MockAppFeatureFlagDefinitionRegistry();
      shouldShowOnboardingUseCase = MockShouldShowOnboardingUseCase();

      when(
        () => serviceLocator.get<ModuleRouteController>(),
      ).thenReturn(routeController);
      when(
        () => serviceLocator.get<AppFeatureFlagDefinitionRegistry>(),
      ).thenReturn(registry);
      when(
        () => serviceLocator.get<ShouldShowOnboardingUseCase>(),
      ).thenReturn(shouldShowOnboardingUseCase);
      when(
        () => routeController.register(OnboardingModuleRoute.onboarding),
      ).thenReturn(null);
      when(() => routeController.registerRedirect(any())).thenReturn(null);
      for (final definition in OnboardingFeatureFlags.all) {
        when(() => registry.register(definition)).thenReturn(null);
      }

      await OnboardingModuleConfigurator().postDependenciesSetup(
        serviceLocator,
      );
      redirect =
          verify(
                () => routeController.registerRedirect(captureAny()),
              ).captured.single
              as ModuleRouteRedirect;
    });

    test('should register the route and every feature flag', () {
      verify(
        () => routeController.register(OnboardingModuleRoute.onboarding),
      ).called(1);
      for (final definition in OnboardingFeatureFlags.all) {
        verify(() => registry.register(definition)).called(1);
      }
    });

    test(
      'should redirect the portfolio route to onboarding when it should show',
      () async {
        shouldShowOnboardingUseCase.stubCall(const Right(true));

        final redirectPath = await redirect(
          _FakeBuildContext(),
          Uri.parse(PortfolioModuleRoute.portfolio.path),
        );

        expect(redirectPath, OnboardingModuleRoute.onboarding.path);
      },
    );

    test(
      'should not redirect the portfolio route when onboarding is done',
      () async {
        shouldShowOnboardingUseCase.stubCall(const Right(false));

        final redirectPath = await redirect(
          _FakeBuildContext(),
          Uri.parse(PortfolioModuleRoute.portfolio.path),
        );

        expect(redirectPath, isNull);
      },
    );

    test('should not redirect other routes', () async {
      shouldShowOnboardingUseCase.stubCall(const Right(true));

      final redirectPath = await redirect(
        _FakeBuildContext(),
        Uri.parse('/experiences'),
      );

      expect(redirectPath, isNull);
    });

    test('should not redirect when the check fails', () async {
      shouldShowOnboardingUseCase.stubCall(
        const Left(ShouldShowOnboardingUnknownFailure()),
      );

      final redirectPath = await redirect(
        _FakeBuildContext(),
        Uri.parse(PortfolioModuleRoute.portfolio.path),
      );

      expect(redirectPath, isNull);
    });
  });
}

class _FakeBuildContext extends Fake implements BuildContext {}

FutureOr<String?> _noRedirect(BuildContext context, Uri requestedUri) => null;
