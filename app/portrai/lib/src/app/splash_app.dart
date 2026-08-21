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
        colorScheme: ColorScheme.fromSwatch().copyWith(
          surface: const Color(0xFF1E1E1E),
          onSurface: const Color(0xFFE0E0E0),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner:
          buildConfig.buildEnvironment.debugShowCheckedModeBanner,
      localeResolutionCallback: (locale, supportedLocales) {
        // First try exact match
        if (locale != null && supportedLocales.contains(locale)) {
          final appLocale = locale.appLocale;
          moduleConfigurators.insert(0, AppLocaleConfigurator(appLocale));
          return locale;
        }

        // If no exact match, try to find by language code
        Locale? resolvedLocale;
        if (locale != null) {
          resolvedLocale = supportedLocales.firstWhere(
            (supportedLocale) =>
                supportedLocale.languageCode == locale.languageCode,
            orElse: () => supportedLocales.first,
          );
        } else {
          resolvedLocale = supportedLocales.first;
        }

        final appLocale = resolvedLocale.appLocale;
        moduleConfigurators.insert(0, AppLocaleConfigurator(appLocale));
        return resolvedLocale;
      },
      home: SplashScreen(
        buildConfig: buildConfig,
        moduleConfigurators: moduleConfigurators,
        onInitializationSuccessful: onInitializationSuccessful,
      ),
    );
  }
}
