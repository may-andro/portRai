import 'package:design_system/src/design_system/design_system.dart';
import 'package:design_system/src/extension/ds_theme_extension.dart';
import 'package:design_system/src/theme/ds_theme.dart';
import 'package:design_system/src/theme/ds_theme_widget.dart';
import 'package:flutter/material.dart';

class DSThemeBuilderWidget extends StatefulWidget {
  const DSThemeBuilderWidget({
    super.key,
    required this.designSystem,
    required this.brightness,
    required this.child,
  });

  final DesignSystem designSystem;
  final Brightness brightness;
  final Widget child;

  /// Builds the theme for [designSystem] in [brightness] ahead of time. A
  /// builder showing it later reuses it instead of building it during a
  /// frame.
  static void precacheTheme({
    required DesignSystem designSystem,
    required Brightness brightness,
  }) {
    DSTheme(brightness: brightness, designSystem: designSystem).theme;
  }

  @override
  State<DSThemeBuilderWidget> createState() => _DSThemeBuilderWidgetState();
}

class _DSThemeBuilderWidgetState extends State<DSThemeBuilderWidget> {
  late DSTheme _dsTheme;
  late ThemeData _themeData;

  @override
  void initState() {
    super.initState();
    _updateTheme();
  }

  @override
  void didUpdateWidget(covariant DSThemeBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brightness != widget.brightness ||
        oldWidget.designSystem != widget.designSystem) {
      _updateTheme();
    }
  }

  // Building ThemeData runs ColorScheme.fromSeed, so it is only looked up when
  // the brightness or the design system changes.
  void _updateTheme() {
    _dsTheme = DSTheme(
      brightness: widget.brightness,
      designSystem: widget.designSystem,
    );
    _themeData = _dsTheme.theme;
  }

  @override
  Widget build(BuildContext context) {
    // The theme subtree is created here, so a MediaQuery change that rebuilds
    // only the clamping wrapper reuses it instead of rebuilding the app.
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 0.75,
      maxScaleFactor: 1.5,
      child: DSThemeWidget(
        dsTheme: _dsTheme,
        child: AnimatedTheme(data: _themeData, child: widget.child),
      ),
    );
  }
}
