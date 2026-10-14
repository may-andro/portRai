import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/section_container_widget.dart';

import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);
  for (final brightness in Brightness.values) {
    for (final background in const <SectionBackground>[
      InverseSectionBackground(),
      SurfaceSectionBackground(),
    ]) {
      testWidgets(
        'should use the surface palette for the header accent when ${background.runtimeType} is used in ${brightness.name} mode',
        (tester) async {
          await tester.pumpWidget(
            TestWidgetWrapper(
              child: DSThemeBuilderWidget(
                brightness: brightness,
                designSystem: DesignSystem.halloween,
                child: SectionContainerWidget(
                  title: 'Services',
                  visibilityKey: 'services',
                  background: background,
                  builder: (_, _) => const SizedBox(height: 100),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 2));
          final context = tester.element(find.byType(SectionContainerWidget));
          final accent = switch (background) {
            InverseSectionBackground() =>
              context.colorPalette.brand.inversePrimary.color,
            SurfaceSectionBackground() => context.colorPalette.accent.color,
          };
          final accentBar = tester.widget<AnimatedContainer>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is AnimatedContainer &&
                  widget.constraints?.maxWidth == 5,
            ),
          );
          final decoration = accentBar.decoration! as BoxDecoration;
          final gradient = decoration.gradient! as LinearGradient;
          expect(gradient.colors.first, accent);
          expect(gradient.colors.last, accent.withAlpha(180));
        },
      );
    }
  }
}
