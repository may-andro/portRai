import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/bloc/_bloc.dart';
import 'package:portrai/src/feature/design_system/presentation/screen/design_system_gallery/design_system_gallery_screen.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/design_system/presentation/screen/design_system_gallery/bloc/mock_design_system_gallery_bloc.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('DesignSystemGalleryScreen', () {
    const designSystemsByMonth = [
      DesignSystem.hogmanay,
      DesignSystem.carnival,
      DesignSystem.holi,
      DesignSystem.sakura,
      DesignSystem.beltane,
      DesignSystem.hogeras,
      DesignSystem.obon,
      DesignSystem.pachamama,
      DesignSystem.chuseok,
      DesignSystem.halloween,
      DesignSystem.diwali,
      DesignSystem.xmas,
    ];
    const loadedState = DesignSystemGalleryLoadedState(
      designSystems: designSystemsByMonth,
      appliedDesignSystem: DesignSystem.holi,
      monthlyDesignSystem: DesignSystem.halloween,
      previewedDesignSystem: DesignSystem.holi,
    );

    late MockDesignSystemGalleryBloc bloc;

    setUpAll(() {
      registerFallbackValue(const LoadDesignSystemGalleryEvent());
    });

    setUp(() async {
      await appServiceLocator.reset();
      bloc = MockDesignSystemGalleryBloc();
      appServiceLocator.registerFactory<DesignSystemGalleryBloc>(() => bloc);
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    const phoneSize = Size(393, 852);
    const desktopSize = Size(1440, 900);

    Future<void> pumpScreen(
      WidgetTester tester, {
      Size screenSize = phoneSize,
    }) async {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const TestWidgetWrapper(child: DesignSystemGalleryScreen()),
      );
      await tester.pump();
      // Lets the gallery build the themes it prepares between frames.
      await tester.pump(const Duration(milliseconds: 100));
    }

    // The festival effects loop, so the deck is given time to settle instead
    // of waiting for every animation to end.
    Future<void> settleDeck(WidgetTester tester) async {
      for (var frame = 0; frame < 40; frame++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('should load the gallery and show a loading indicator', (
      tester,
    ) async {
      bloc.stubState(const DesignSystemGalleryLoadingState());

      await pumpScreen(tester);

      expect(find.byType(DSLoadingWidget), findsOneWidget);
      verify(() => bloc.add(const LoadDesignSystemGalleryEvent())).called(1);
    });

    testWidgets(
      'should show the previewed theme in front and mark it as in use',
      (tester) async {
        bloc.stubState(loadedState);

        await pumpScreen(tester);

        expect(find.text('Holi'), findsOneWidget);
        expect(find.text('Splashes of colour everywhere'), findsOneWidget);
        final applyButton = tester.widget<DSButtonWidget>(
          find.byType(DSButtonWidget),
        );
        expect(applyButton.label, 'In use');
        expect(applyButton.isDisabled, isTrue);
      },
    );

    testWidgets('should preview the next theme when the next arrow is tapped', (
      tester,
    ) async {
      bloc.stubState(loadedState);
      await pumpScreen(tester);

      await tester.tap(find.byTooltip('Next theme'));
      await settleDeck(tester);

      verify(
        () =>
            bloc.add(const PreviewDesignSystemClickEvent(DesignSystem.sakura)),
      ).called(1);
    });

    testWidgets(
      'should hide the tossed card while the next one settles in front',
      (tester) async {
        bloc.stubState(loadedState);
        await pumpScreen(tester);

        await tester.tap(find.byTooltip('Next theme'));
        for (var frame = 0; frame < 25; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        // The spring is close to rest, with the tossed card almost a card
        // width away.
        for (var frame = 0; frame < 40; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          final tossedCardOpacities = tester
              .widgetList<Opacity>(
                find.ancestor(
                  of: find.text('Holi'),
                  matching: find.byType(Opacity),
                ),
              )
              .map((opacity) => opacity.opacity);
          expect(tossedCardOpacities, everyElement(0));
        }
      },
    );

    testWidgets(
      'should preview the previous theme when the front card is flung right',
      (tester) async {
        bloc.stubState(loadedState);
        await pumpScreen(tester);

        await tester.fling(find.text('Holi'), const Offset(200, 0), 1500);
        await settleDeck(tester);

        verify(
          () => bloc.add(
            const PreviewDesignSystemClickEvent(DesignSystem.carnival),
          ),
        ).called(1);
      },
    );

    testWidgets('should take the deck to a month when its dot is tapped', (
      tester,
    ) async {
      bloc.stubState(loadedState);
      await pumpScreen(tester);

      await tester.tap(find.bySemanticsLabel('Christmas'));
      await settleDeck(tester);

      verify(
        () => bloc.add(const PreviewDesignSystemClickEvent(DesignSystem.xmas)),
      ).called(1);
    });

    testWidgets(
      'should apply the previewed theme when the apply button is tapped',
      (tester) async {
        bloc.stubState(
          loadedState.copyWith(previewedDesignSystem: DesignSystem.halloween),
        );
        await pumpScreen(tester);

        await tester.tap(find.text('Apply theme'));
        await tester.pump();

        verify(() => bloc.add(const ApplyDesignSystemClickEvent())).called(1);
      },
    );

    for (final screenSize in [phoneSize, desktopSize]) {
      testWidgets(
        'should keep the apply button in place when the previewed theme '
        'changes, on a $screenSize screen',
        (tester) async {
          Future<Offset> applyButtonPositionFor(
            DesignSystem designSystem,
          ) async {
            bloc = MockDesignSystemGalleryBloc()
              ..stubState(
                loadedState.copyWith(previewedDesignSystem: designSystem),
              );
            await pumpScreen(tester, screenSize: screenSize);
            final position = tester.getTopLeft(find.byType(DSButtonWidget));
            await tester.pumpWidget(const SizedBox());
            return position;
          }

          final positions = [
            for (final designSystem in designSystemsByMonth)
              await applyButtonPositionFor(designSystem),
          ];

          expect(positions.toSet(), hasLength(1));
        },
      );
    }

    testWidgets(
      'should place the controls beside the deck on a landscape screen',
      (tester) async {
        bloc.stubState(loadedState);

        await pumpScreen(tester, screenSize: desktopSize);

        final deckRight = tester.getTopRight(find.text('Holi').first).dx;
        final applyButtonLeft = tester
            .getTopLeft(find.byType(DSButtonWidget))
            .dx;
        expect(applyButtonLeft, greaterThan(desktopSize.width / 2));
        expect(applyButtonLeft, greaterThan(deckRight));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'should stack the deck above the controls on a portrait screen',
      (tester) async {
        bloc.stubState(loadedState);

        await pumpScreen(tester);

        final deckBottom = tester
            .getBottomLeft(find.text('Splashes of colour everywhere'))
            .dy;
        final applyButtonTop = tester
            .getTopLeft(find.byType(DSButtonWidget))
            .dy;
        expect(applyButtonTop, greaterThan(deckBottom));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('should tell the user when applying the theme fails', (
      tester,
    ) async {
      bloc.stubState(
        loadedState.copyWith(
          previewedDesignSystem: DesignSystem.halloween,
          failure: const ApplyDesignSystemUnknownFailure(),
        ),
      );

      await pumpScreen(tester);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
