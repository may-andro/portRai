import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  group('DesignSystemCardWidget', () {
    Future<void> pumpCard(
      WidgetTester tester, {
      VoidCallback? onClicked,
    }) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Scaffold(
            body: DesignSystemCardWidget(onClicked: onClicked ?? () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('should name the theme in use', (tester) async {
      await pumpCard(tester);

      expect(find.text('App theme'), findsOneWidget);
      expect(find.text('Beltane'), findsOneWidget);
    });

    testWidgets('should report the tap when the card is tapped', (
      tester,
    ) async {
      var clickCount = 0;
      await pumpCard(tester, onClicked: () => clickCount++);

      await tester.tap(find.text('App theme'));
      await tester.pumpAndSettle();

      expect(clickCount, 1);
      expect(tester.takeException(), isNull);
    });
  });
}
