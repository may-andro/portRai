import 'package:design_system/design_system.dart';
import 'package:design_system/src/extension/ds_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/test_wrapper_widget.dart';

class _TestWidget extends StatelessWidget {
  const _TestWidget();

  @override
  Widget build(BuildContext context) {
    final color = context.theme.colorPalette.brand.primary.color;
    return Text('Find me', style: TextStyle(color: color));
  }
}

class _BuildCountingWidget extends StatelessWidget {
  const _BuildCountingWidget({required this.onBuild});

  final ValueChanged<double> onBuild;

  @override
  Widget build(BuildContext context) {
    context.theme;
    onBuild(context.space());
    return const SizedBox.shrink();
  }
}

Widget _themedApp({
  required MediaQueryData mediaQueryData,
  Brightness brightness = Brightness.light,
  required Widget child,
}) {
  return MediaQuery(
    data: mediaQueryData,
    child: DSThemeBuilderWidget(
      brightness: brightness,
      designSystem: DesignSystem.beltane,
      child: child,
    ),
  );
}

void main() {
  group(DSTheme, () {
    test('should be equal when brightness and design system match', () {
      final theme = DSTheme(
        brightness: Brightness.dark,
        designSystem: DesignSystem.beltane,
      );

      expect(
        theme,
        DSTheme(
          brightness: Brightness.dark,
          designSystem: DesignSystem.beltane,
        ),
      );
      expect(
        theme,
        isNot(
          DSTheme(
            brightness: Brightness.light,
            designSystem: DesignSystem.beltane,
          ),
        ),
      );
    });

    test('should reuse the built theme data for an equal theme', () {
      final themeData = DSTheme(
        brightness: Brightness.dark,
        designSystem: DesignSystem.obon,
      ).theme;

      expect(
        DSTheme(
          brightness: Brightness.dark,
          designSystem: DesignSystem.obon,
        ).theme,
        same(themeData),
      );
    });
  });

  group(DSThemeBuilderWidget, () {
    testWidgets('should show the theme data built by precacheTheme', (
      tester,
    ) async {
      DSThemeBuilderWidget.precacheTheme(
        designSystem: DesignSystem.holi,
        brightness: Brightness.dark,
      );

      await tester.pumpWidget(
        const DSThemeBuilderWidget(
          brightness: Brightness.dark,
          designSystem: DesignSystem.holi,
          child: SizedBox.shrink(),
        ),
      );

      final animatedTheme = tester.widget<AnimatedTheme>(
        find.byType(AnimatedTheme),
      );
      expect(
        animatedTheme.data,
        same(
          DSTheme(
            brightness: Brightness.dark,
            designSystem: DesignSystem.holi,
          ).theme,
        ),
      );
    });

    testWidgets('should not rebuild theme dependants when view insets change', (
      WidgetTester tester,
    ) async {
      var buildCount = 0;
      final child = _BuildCountingWidget(onBuild: (_) => buildCount++);
      const mediaQueryData = MediaQueryData(size: Size(400, 800));

      await tester.pumpWidget(
        _themedApp(mediaQueryData: mediaQueryData, child: child),
      );
      await tester.pumpWidget(
        _themedApp(
          mediaQueryData: mediaQueryData.copyWith(
            viewInsets: const EdgeInsets.only(bottom: 300),
          ),
          child: child,
        ),
      );

      expect(buildCount, 1);
    });

    testWidgets('should rebuild theme dependants when text scale changes', (
      WidgetTester tester,
    ) async {
      final spaces = <double>[];
      final child = _BuildCountingWidget(onBuild: spaces.add);
      const mediaQueryData = MediaQueryData(size: Size(400, 800));

      await tester.pumpWidget(
        _themedApp(mediaQueryData: mediaQueryData, child: child),
      );
      await tester.pumpWidget(
        _themedApp(
          mediaQueryData: mediaQueryData.copyWith(
            textScaler: const TextScaler.linear(3),
          ),
          child: child,
        ),
      );

      expect(spaces, hasLength(2));
      expect(spaces.last, spaces.first * 1.5);
    });

    testWidgets('should rebuild theme dependants when brightness changes', (
      WidgetTester tester,
    ) async {
      var buildCount = 0;
      final child = _BuildCountingWidget(onBuild: (_) => buildCount++);
      const mediaQueryData = MediaQueryData(size: Size(400, 800));

      await tester.pumpWidget(
        _themedApp(mediaQueryData: mediaQueryData, child: child),
      );
      await tester.pumpWidget(
        _themedApp(
          mediaQueryData: mediaQueryData,
          brightness: Brightness.dark,
          child: child,
        ),
      );

      expect(buildCount, 2);
    });

    testWidgets('should able to access $DSTheme via $DSThemeBuilderWidget', (
      WidgetTester tester,
    ) async {
      const testWidget = TestWidgetWrapper(
        brightness: Brightness.light,
        designSystem: DesignSystem.beltane,
        child: _TestWidget(),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      final finder = find.textContaining('Find me');
      final Text widget = tester.widget(finder);
      expect(widget.style?.color, isNotNull);
      expect(widget.style?.color, const DSColor(0xFF2E7D32).color);
    });
  });
}
