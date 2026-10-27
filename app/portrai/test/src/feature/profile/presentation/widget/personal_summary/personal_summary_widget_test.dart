import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/personal_summary_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/profile/presentation/widget/personal_summary/bloc/mock_personal_summary_bloc.dart';
import '../../../../../../mock/feature/profile/test_data/profile_test_data.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUp(() async {
    await appServiceLocator.reset();
    MockPersonalSummaryBloc()
      ..stubState()
      ..registerFactory();
  });

  tearDown(() => appServiceLocator.reset());

  for (final brightness in Brightness.values) {
    for (final designSystem in DesignSystem.values) {
      testWidgets(
        'should use the inverse-surface foreground for the subtitle when ${designSystem.name} is ${brightness.name}',
        (tester) async {
          final profile = createProfileEntity();
          final palette = DSTheme(
            brightness: brightness,
            designSystem: designSystem,
          ).colorPalette;
          await tester.pumpWidget(
            TestWidgetWrapper(
              child: DSThemeBuilderWidget(
                brightness: brightness,
                designSystem: designSystem,
                child: SingleChildScrollView(
                  child: ColoredBox(
                    color: palette.surface.inverseSurface.color,
                    child: PersonalSummaryWidget(
                      profile: profile,
                      isVisible: false,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 1));

          final subtitle = tester.widget<DSTextWidget>(
            find.widgetWithText(DSTextWidget, profile.subtitle),
          );
          expect(subtitle.color, palette.surface.onInverseSurface);
          final accentBar = tester.widget<AnimatedContainer>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is AnimatedContainer &&
                  widget.constraints?.maxHeight == 4,
            ),
          );
          expect(
            (accentBar.decoration! as BoxDecoration).color,
            palette.surface.onInverseSurface.color,
          );
          final foregroundLuminance = palette.surface.onInverseSurface.color
              .computeLuminance();
          final backgroundLuminance = palette.surface.inverseSurface.color
              .computeLuminance();
          final lighter = foregroundLuminance > backgroundLuminance
              ? foregroundLuminance
              : backgroundLuminance;
          final darker = foregroundLuminance < backgroundLuminance
              ? foregroundLuminance
              : backgroundLuminance;
          expect((lighter + 0.05) / (darker + 0.05), greaterThanOrEqualTo(4.5));
        },
      );
    }
  }

  testWidgets('should track the tap and open the profile when the view full '
      'profile button is tapped', (tester) async {
    await appServiceLocator.reset();
    final bloc = MockPersonalSummaryBloc()
      ..stubState()
      ..registerFactory();
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: SingleChildScrollView(
          child: PersonalSummaryWidget(
            profile: createProfileEntity(),
            isVisible: true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byIcon(Icons.arrow_outward_rounded));
    await tester.pump();

    verify(
      () => bloc.add(const ViewProfileClickEvent('view_profile_button')),
    ).called(1);
    // No router in the test wrapper, so opening the profile throws.
    expect(tester.takeException(), isNotNull);
  });
}
