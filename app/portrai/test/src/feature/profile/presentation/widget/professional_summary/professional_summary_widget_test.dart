import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/bloc/_bloc.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../../mock/feature/ai_image_gen/presentation/bloc/mock_ai_image_bloc.dart';
import '../../../../../../mock/feature/profile/presentation/widget/professional_summary/bloc/mock_professional_summary_bloc.dart';
import '../../../../../../mock/feature/profile/test_data/profile_test_data.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  final profile = createProfileEntity();

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  tearDown(() => appServiceLocator.reset());

  Future<void> pumpWidget(
    WidgetTester tester, {
    required Size size,
    List<String> projectImages = const [],
    Brightness brightness = Brightness.light,
    DesignSystem designSystem = DesignSystem.beltane,
    ProfessionalSummaryVariant variant = const OverviewProfessionalSummary(),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    MockProfessionalSummaryBloc()
      ..stubState(LoadedState(profile: profile))
      ..registerFactory();
    MockAiImageBloc()
      ..stubLoadingState()
      ..registerFactory();

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: DSThemeBuilderWidget(
          brightness: brightness,
          designSystem: designSystem,
          child: SingleChildScrollView(
            child: ProfessionalSummaryWidget(
              profile: profile,
              variant: variant,
              isVisible: true,
              height: size.height,
              projectImages: projectImages,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
  }

  const sizes = {
    'mobile': Size(390, 844),
    'tablet': Size(820, 1180),
    'desktop': Size(1440, 900),
  };

  const variants = <String, ProfessionalSummaryVariant>{
    'overview': OverviewProfessionalSummary(),
    'engineering': EngineeringProfessionalSummary(stack: ['Dart', 'Kotlin']),
    'hiring': HiringProfessionalSummary(),
  };

  for (final size in sizes.entries) {
    for (final variant in variants.entries) {
      testWidgets(
        'should render without overflow when ${variant.key} is ${size.key}',
        (tester) async {
          await pumpWidget(tester, size: size.value, variant: variant.value);

          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'should not grow the section beyond the overview when every variant is ${size.key}',
      (tester) async {
        final sizesByVariant = <String, Size>{};
        for (final variant in variants.entries) {
          await appServiceLocator.reset();
          await pumpWidget(tester, size: size.value, variant: variant.value);
          sizesByVariant[variant.key] = tester.getSize(
            find.byType(ProfessionalSummaryWidget),
          );
        }

        for (final entry in sizesByVariant.entries) {
          expect(
            entry.value.height,
            lessThanOrEqualTo(sizesByVariant['overview']!.height),
            reason: entry.key,
          );
        }
      },
    );
  }

  testWidgets('should show a single GitHub entry when engineering', (
    tester,
  ) async {
    await pumpWidget(
      tester,
      size: sizes['desktop']!,
      variant: variants['engineering']!,
    );

    final githubImages = find.byWidgetPredicate(
      (widget) =>
          widget is DSNetworkImageWidget &&
          widget.url == profile.socialLinks.first.image,
    );
    expect(githubImages, findsOneWidget);
  });

  testWidgets('should show the tech stack illustration when engineering', (
    tester,
  ) async {
    await pumpWidget(
      tester,
      size: sizes['desktop']!,
      variant: variants['engineering']!,
    );

    expect(find.byType(DSLottieIllustrationWidget), findsOneWidget);
  });

  testWidgets('should show availability and resume first when hiring', (
    tester,
  ) async {
    await pumpWidget(
      tester,
      size: sizes['desktop']!,
      variant: variants['hiring']!,
    );

    expect(find.text(profile.availability.status), findsOneWidget);
    expect(find.text(profile.title), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    for (final designSystem in DesignSystem.values) {
      testWidgets(
        'should use matching social icon colors at rest and on hover when ${designSystem.name} is ${brightness.name}',
        (tester) async {
          await pumpWidget(
            tester,
            size: sizes['desktop']!,
            brightness: brightness,
            designSystem: designSystem,
          );
          final socialImage = find.byWidgetPredicate(
            (widget) =>
                widget is DSNetworkImageWidget &&
                widget.url == profile.socialLinks.first.image,
          );
          final context = tester.element(socialImage);
          final palette = context.colorPalette;
          expect(
            tester.widget<DSNetworkImageWidget>(socialImage).color,
            palette.brand.onSecondaryContainer,
          );
          final cardFinder = find.ancestor(
            of: socialImage,
            matching: find.byType(AnimatedContainer),
          );
          BoxDecoration cardDecoration() =>
              tester.widget<AnimatedContainer>(cardFinder).decoration!
                  as BoxDecoration;
          expect(
            cardDecoration().color,
            palette.brand.secondaryContainer.color,
          );
          expect(
            cardDecoration().border,
            Border.all(color: palette.outline.outlineVariant.color),
          );

          final hoverRegion = tester.widget<MouseRegion>(
            find
                .ancestor(
                  of: socialImage,
                  matching: find.byWidgetPredicate(
                    (widget) => widget is MouseRegion && widget.onEnter != null,
                  ),
                )
                .first,
          );
          hoverRegion.onEnter!(const PointerEnterEvent());
          await tester.pump(const Duration(milliseconds: 300));
          final hoverColor = Color.alphaBlend(
            palette.brand.secondary.color.withAlpha(20),
            palette.brand.secondaryContainer.color,
          );
          expect(cardDecoration().color, hoverColor);
          final iconLuminance = palette.brand.onSecondaryContainer.color
              .computeLuminance();
          for (final background in [
            palette.brand.secondaryContainer.color,
            hoverColor,
          ]) {
            final backgroundLuminance = background.computeLuminance();
            final lighter = iconLuminance > backgroundLuminance
                ? iconLuminance
                : backgroundLuminance;
            final darker = iconLuminance < backgroundLuminance
                ? iconLuminance
                : backgroundLuminance;
            expect((lighter + 0.05) / (darker + 0.05), greaterThanOrEqualTo(3));
          }
          hoverRegion.onExit!(const PointerExitEvent());
          await tester.pump(const Duration(milliseconds: 300));
        },
      );
    }
  }

  for (final entry in sizes.entries) {
    testWidgets(
      'should show current role and resume action when rendered on ${entry.key}',
      (tester) async {
        await pumpWidget(tester, size: entry.value);

        expect(
          find.textContaining(profile.currentCompany, findRichText: true),
          findsOneWidget,
        );
        expect(find.textContaining(profile.subtitle), findsOneWidget);
        expect(find.text('Resume'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('should render without errors when project images are provided', (
    tester,
  ) async {
    await pumpWidget(
      tester,
      size: sizes['mobile']!,
      projectImages: ['https://example.com/a.png', 'https://example.com/b.png'],
    );

    expect(tester.takeException(), isNull);
  });
}
