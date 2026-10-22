import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/app/splash_app.dart';
import 'package:portrai/src/feature/locale/locale.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../mock/feature/locale/test_data/locale_test_data.dart';

void main() {
  group('SplashApp', () {
    tearDown(() async {
      await appServiceLocator.reset();
    });

    SplashApp buildSplashApp(List<ModuleConfigurator> moduleConfigurators) {
      return SplashApp(
        buildConfig: BuildConfig(buildEnvironment: BuildEnvironment.prod),
        moduleConfigurators: moduleConfigurators,
        onInitializationSuccessful: (_) {},
      );
    }

    AppLocale registeredAppLocale(ModuleConfigurator configurator) {
      configurator.registerDependencies(appServiceLocator);
      return appServiceLocator.get<AppLocale>();
    }

    test('should add the app locale first when the locale is resolved', () {
      final moduleConfigurators = <ModuleConfigurator>[];

      final resolvedLocale = buildSplashApp(
        moduleConfigurators,
      ).resolveLocale(const Locale('nl'), createSupportedLocales());

      expect(resolvedLocale, const Locale('nl'));
      expect(moduleConfigurators, [isA<AppLocaleConfigurator>()]);
      expect(registeredAppLocale(moduleConfigurators.single), AppLocale('nl'));
    });

    test('should keep one app locale with the latest locale when the locale '
        'is resolved again', () {
      final moduleConfigurators = <ModuleConfigurator>[];
      final splashApp = buildSplashApp(moduleConfigurators);

      splashApp.resolveLocale(const Locale('nl'), createSupportedLocales());
      final resolvedLocale = splashApp.resolveLocale(
        const Locale('es', 'MX'),
        createSupportedLocales(),
      );

      expect(resolvedLocale, const Locale('es'));
      expect(moduleConfigurators, hasLength(1));
      expect(registeredAppLocale(moduleConfigurators.single), AppLocale('es'));
    });

    test('should fall back to the first supported locale when no locale '
        'matches', () {
      final moduleConfigurators = <ModuleConfigurator>[];

      final resolvedLocale = buildSplashApp(
        moduleConfigurators,
      ).resolveLocale(const Locale('fr'), createSupportedLocales());

      expect(resolvedLocale, const Locale('en'));
    });
  });
}
