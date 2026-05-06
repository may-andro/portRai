import 'package:alchemist/alchemist.dart';
import 'package:design_system/src/design_system/design_system.dart';
import 'package:design_system/src/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recase/recase.dart';

/// A [TestCase] holds the description of the test, and the widget to be
/// rendered.
class TestCase {
  const TestCase(this.description, this.widget);

  final String description;
  final Widget widget;
}

/// This testing utility function renders a list of [testCases] in a golden file
///
/// The [widgetUnderTest] is used for generating the correct file names and
/// test descriptions for all brightness levels.
///
/// The [label] is an optional text that, if provided, will be rendered onto the
/// golden images (below the title) and will be part of the golden files' name.
void groupGoldenForBrightnessAndDS(
  String widgetUnderTest,
  List<TestCase> Function(DSTheme theme) testCasesCallback, {
  String? label,
}) {
  for (final brightness in Brightness.values) {
    for (final designSystem in DesignSystem.values) {
      final dsTheme = DSTheme(
        brightness: brightness,
        designSystem: designSystem,
      );
      final testCases = testCasesCallback(dsTheme);
      groupGolden(
        widgetUnderTest,
        brightness,
        designSystem,
        testCases,
        label: label,
      );
    }
  }
}

/// This testing utility function renders a list of [testCases] in a golden file
///
/// The [widgetUnderTest] is used for generating the correct file names and
/// test descriptions.
///
/// The [label] is an optional text that, if provided, will be rendered onto the
/// golden images (below the title) and will be part of the golden files' name.
void groupGolden(
  String widgetUnderTest,
  Brightness brightness,
  DesignSystem designSystem,
  List<TestCase> testCases, {
  String? label,
}) {
  group(widgetUnderTest, () {
    goldenTest(
      'on $brightness with $designSystem',
      fileName:
          '${_toSnakeCase(widgetUnderTest)}_'
          '${label == null ? '' : '${_toSnakeCase(label).replaceAll(' ', '')}_'}'
          '${designSystem.name.snakeCase}_'
          '${brightness.title.toLowerCase().snakeCase..replaceAll(' ', '')}',
      // Use a finite pump strategy so infinite animations (loaders, etc.) don't
      // cause pumpAndSettle timeouts.
      pumpBeforeTest: (tester) async {
        await tester.pump(const Duration(milliseconds: 100));
      },
      pumpWidget: (tester, widget) async {
        await tester.pumpWidget(widget);
        await tester.pump(const Duration(milliseconds: 100));
      },
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 600),
        children: testCases.map((testCase) {
          return _TestCaseWidget(
            testCase,
            designSystem: designSystem,
            brightness: brightness,
          );
        }).toList(),
      ),
    );
  });
}

/// The test case widget that renders the test description and the
/// widget under test.
class _TestCaseWidget extends StatelessWidget {
  const _TestCaseWidget(
    this.testCase, {
    required this.brightness,
    required this.designSystem,
  });

  final TestCase testCase;
  final Brightness brightness;
  final DesignSystem designSystem;

  @override
  Widget build(BuildContext context) {
    return GoldenTestScenario(
      name: testCase.description,
      child: DSThemeBuilderWidget(
        brightness: brightness,
        designSystem: designSystem,
        child: testCase.widget,
      ),
    );
  }
}

extension on Brightness {
  String get title {
    switch (this) {
      case Brightness.dark:
        return 'Dark Mode';
      case Brightness.light:
        return 'Light Mode';
    }
  }
}

/// Converts a [camelCase] string (including acronyms like "DS", "ID") to
/// snake_case without splitting consecutive capitals individually.
///
/// Examples:
///   DSButtonWidget     → ds_button_widget
///   DSIconButtonWidget → ds_icon_button_widget
///   DSTextWidget       → ds_text_widget
String _toSnakeCase(String camelCase) {
  return camelCase
      // Insert underscore between a run of uppercase letters and an
      // uppercase letter that is followed by a lowercase letter.
      // "DSButton" → "DS_Button"
      .replaceAllMapped(
        RegExp(r'([A-Z]+)([A-Z][a-z])'),
        (m) => '${m[1]}_${m[2]}',
      )
      // Insert underscore between a lowercase letter / digit and an uppercase letter.
      // "Button_Widget" → already correct; "textWidget" → "text_Widget"
      .replaceAllMapped(
        RegExp(r'([a-z\d])([A-Z])'),
        (m) => '${m[1]}_${m[2]}',
      )
      .toLowerCase();
}
