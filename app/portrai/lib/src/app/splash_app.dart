import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/l10n/l10n.dart';

import 'package:portrai/src/feature/locale/locale.dart';
import 'package:portrai/src/feature/splash/splash.dart';

class SplashApp extends StatelessWidget {
  const SplashApp({
    required this.buildConfig,
    required this.moduleConfigurators,
    required this.onInitializationSuccessful,
    super.key,
  });

  final BuildConfig buildConfig;
  final List<ModuleConfigurator> moduleConfigurators;
  final void Function(DesignSystem) onInitializationSuccessful;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PortRai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          surface: const Color(0xFFF6F6F6),
          onSurface: const Color(0xFF212121),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark)
            .copyWith(
              surface: const Color(0xFF1E1E1E),
              onSurface: const Color(0xFFE0E0E0),
            ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner:
          buildConfig.buildEnvironment.debugShowCheckedModeBanner,
      localeResolutionCallback: resolveLocale,
      home: SplashScreen(
        buildConfig: buildConfig,
        moduleConfigurators: moduleConfigurators,
        onInitializationSuccessful: onInitializationSuccessful,
      ),
    );
  }

  /// Picks the supported locale for [locale] and registers it as the app
  /// locale. The locale can be resolved more than once, so the app locale is
  /// replaced instead of added again.
  @visibleForTesting
  Locale resolveLocale(Locale? locale, Iterable<Locale> supportedLocales) {
    final resolvedLocale = switch (locale) {
      final locale? when supportedLocales.contains(locale) => locale,
      final locale? => supportedLocales.firstWhere(
        (supportedLocale) =>
            supportedLocale.languageCode == locale.languageCode,
        orElse: () => supportedLocales.first,
      ),
      null => supportedLocales.first,
    };
    final appLocaleConfigurator = AppLocaleConfigurator(
      resolvedLocale.appLocale,
    );
    final appLocaleConfiguratorIndex = moduleConfigurators.indexWhere(
      (configurator) => configurator is AppLocaleConfigurator,
    );
    if (appLocaleConfiguratorIndex == -1) {
      moduleConfigurators.insert(0, appLocaleConfigurator);
    } else {
      moduleConfigurators[appLocaleConfiguratorIndex] = appLocaleConfigurator;
    }
    return resolvedLocale;
  }
}
