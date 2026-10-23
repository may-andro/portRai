import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';
import 'package:portrai/src/widget/page_header_widget.dart';

import '../../util/test_wrapper_widget.dart';

void main() {
  group('PageAppBarWidget', () {
    Future<void> pumpAppBar(WidgetTester tester) {
      return tester.pumpWidget(
        const TestWidgetWrapper(
          child: CustomScrollView(
            slivers: [
              PageAppBarWidget(title: 'Title', actions: [Icon(Icons.refresh)]),
            ],
          ),
        ),
      );
    }

    testWidgets(
      'should show the actions at the end of the logo header when the '
      'platform shows the header',
      (tester) async {
        await pumpAppBar(tester);

        expect(
          find.descendant(
            of: find.byType(PageHeaderWidget),
            matching: find.byIcon(Icons.refresh),
          ),
          findsOneWidget,
        );
        final screenWidth =
            tester.view.physicalSize.width / tester.view.devicePixelRatio;
        final headerRight = tester
            .getTopRight(find.byType(PageHeaderWidget))
            .dx;
        final actionRight = tester.getTopRight(find.byIcon(Icons.refresh)).dx;
        expect(headerRight, screenWidth);
        expect(actionRight, greaterThan(screenWidth * 0.9));
      },
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    );

    testWidgets(
      'should show the actions in the title bar when the platform shows a '
      'title bar',
      (tester) async {
        await pumpAppBar(tester);

        expect(find.byType(PageHeaderWidget), findsNothing);
        expect(find.text('Title'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SliverAppBar),
            matching: find.byIcon(Icons.refresh),
          ),
          findsOneWidget,
        );
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    for (final entry in const {
      'phone': Size(390, 844),
      'tablet': Size(820, 1180),
    }.entries) {
      testWidgets('should start the logo at the screen padding when shown on a '
          '${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await pumpAppBar(tester);

        final context = tester.element(find.byType(PageHeaderWidget));
        expect(
          tester
              .getTopLeft(
                find.descendant(
                  of: find.byType(PageHeaderWidget),
                  matching: find.byType(DSLottieIllustrationWidget),
                ),
              )
              .dx,
          context.screenHorizontalPadding.left,
        );
      }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
    }

    testWidgets('should keep the logo near the corner when shown on desktop', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpAppBar(tester);

      final context = tester.element(find.byType(PageHeaderWidget));
      expect(
        tester
            .getTopLeft(
              find.descendant(
                of: find.byType(PageHeaderWidget),
                matching: find.byType(DSLottieIllustrationWidget),
              ),
            )
            .dx,
        context.space(factor: 2),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });

  group('PageTopBarWidget', () {
    Future<void> pumpPushedTopBar(WidgetTester tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  // The header logo loops, so its ticker is muted to let
                  // pumpAndSettle finish.
                  builder: (_) => const TickerMode(
                    enabled: false,
                    child: Scaffold(
                      body: PageTopBarWidget(
                        title: 'Title',
                        actions: [Icon(Icons.refresh)],
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'should show the logo header with the actions and no back button when '
      'the platform shows the header',
      (tester) async {
        await pumpPushedTopBar(tester);

        expect(find.byType(PageHeaderWidget), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    );

    testWidgets(
      'should show the title, the actions and the close button but no back '
      'button when the platform shows a title bar',
      (tester) async {
        await pumpPushedTopBar(tester);

        expect(find.text('Title'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  });
}
