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
  });
}
