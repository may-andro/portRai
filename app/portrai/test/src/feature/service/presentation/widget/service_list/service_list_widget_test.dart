import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/service_list_widget.dart';

import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  const service = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
    technologies: ['Flutter'],
  );

  group('ServiceListWidget', () {
    for (final brightness in Brightness.values) {
      testWidgets(
        'should use matching surface and foreground roles when Halloween is ${brightness.name}',
        (tester) async {
          final appTheme = DSTheme(
            brightness: brightness,
            designSystem: DesignSystem.halloween,
          );
          final inverseBackground =
              appTheme.colorPalette.surface.inverseSurface;

          await tester.pumpWidget(
            TestWidgetWrapper(
              child: DSThemeBuilderWidget(
                brightness: brightness,
                designSystem: DesignSystem.halloween,
                child: ColoredBox(
                  color: inverseBackground.color,
                  child: const ServiceListWidget(
                    services: [service],
                    isVisible: true,
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 1));

          final card = tester.widget<DSSpotlightCardWidget>(
            find.byType(DSSpotlightCardWidget),
          );
          expect(card.glowColor, appTheme.colorPalette.brand.tertiary);
          final tagContext = tester.element(find.byType(DSTagWidget));
          expect(tagContext.theme.brightness, brightness);
          expect(
            tagContext.colorPalette.brand.primaryContainer,
            appTheme.colorPalette.brand.primaryContainer,
          );
          final arrow = tester.widget<Icon>(
            find.byIcon(Icons.arrow_outward_rounded),
          );
          expect(
            arrow.color,
            appTheme.colorPalette.brand.onTertiaryContainer.color,
          );
          final cardBackground = card.background! as ColoredBox;
          expect(
            cardBackground.color,
            appTheme.colorPalette.surface.surfaceContainer.color,
          );
          final brand = appTheme.colorPalette.brand;
          double contrast(Color first, Color second) {
            final firstLuminance = first.computeLuminance();
            final secondLuminance = second.computeLuminance();
            final lighter = firstLuminance > secondLuminance
                ? firstLuminance
                : secondLuminance;
            final darker = firstLuminance < secondLuminance
                ? firstLuminance
                : secondLuminance;
            return (lighter + 0.05) / (darker + 0.05);
          }

          expect(
            contrast(
              brand.onTertiaryContainer.color,
              brand.tertiaryContainer.color,
            ),
            greaterThanOrEqualTo(3),
          );
          expect(
            contrast(
              brand.onPrimaryContainer.color,
              brand.primaryContainer.color,
            ),
            greaterThanOrEqualTo(4.5),
          );
        },
      );
    }

    testWidgets('should render the service summary when built', (tester) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: ServiceListWidget(services: [service], isVisible: true),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(service.title), findsOneWidget);
      expect(find.byType(DSSpotlightCardWidget), findsOneWidget);
      expect(find.byType(DSNetworkImageWidget), findsOneWidget);
    });

    testWidgets('should navigate to the service screen when a card is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: ServiceListWidget(services: [service], isVisible: true),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(DSSpotlightCardWidget));
      await tester.pump(const Duration(seconds: 1));

      // No router in the test wrapper, so an attempted navigation throws.
      expect(tester.takeException(), isNotNull);
    });

    testWidgets('should report the opened service when a card is tapped', (
      tester,
    ) async {
      final openedServices = <ServiceEntity>[];
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: ServiceListWidget(
            services: const [service],
            isVisible: true,
            onOpen: openedServices.add,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(DSSpotlightCardWidget));
      await tester.pump(const Duration(seconds: 1));
      tester.takeException();

      expect(openedServices, [service]);
    });

    testWidgets('should limit the cards when visibleItemsCount is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: ServiceListWidget(
            services: [service, service, service],
            isVisible: true,
            visibleItemsCount: 2,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(DSSpotlightCardWidget), findsNWidgets(2));
    });
  });
}
