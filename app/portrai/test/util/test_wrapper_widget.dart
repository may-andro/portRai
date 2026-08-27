import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';

/// Wraps [child] with the localization delegates and design system theme
/// needed to render widgets that rely on `context.localizations` and the
/// design system's `context.colorPalette`/`context.typography`/etc.
class TestWidgetWrapper extends StatelessWidget {
  const TestWidgetWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (_, child) {
        return DSThemeBuilderWidget(
          brightness: Brightness.light,
          designSystem: DesignSystem.beltane,
          child: child!,
        );
      },
      home: Scaffold(body: child),
    );
  }
}
