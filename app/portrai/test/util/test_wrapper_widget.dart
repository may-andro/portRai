import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';

/// Wraps [child] with the localization delegates and design system theme
/// needed to render widgets that rely on `context.localizations` and the
/// design system's `context.colorPalette`/`context.typography`/etc.
class TestWidgetWrapper extends StatelessWidget {
  const TestWidgetWrapper({super.key, required this.child, this.routerConfig});

  final Widget child;
  final RouterConfig<Object>? routerConfig;

  @override
  Widget build(BuildContext context) {
    if (routerConfig != null) {
      return MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: routerConfig,
        builder: _buildTheme,
      );
    }
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: _buildTheme,
      home: Scaffold(body: child),
    );
  }

  Widget _buildTheme(BuildContext context, Widget? child) =>
      DSThemeBuilderWidget(
        brightness: Brightness.light,
        designSystem: DesignSystem.beltane,
        child: child!,
      );
}
