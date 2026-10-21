import 'package:design_system/src/theme/ds_theme.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
final class DSThemeWidget extends InheritedWidget {
  const DSThemeWidget({super.key, required this.dsTheme, required super.child});

  final DSTheme dsTheme;

  @override
  bool updateShouldNotify(covariant DSThemeWidget oldWidget) {
    return dsTheme != oldWidget.dsTheme;
  }

  static DSTheme of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DSThemeWidget>()!.dsTheme;
  }
}
