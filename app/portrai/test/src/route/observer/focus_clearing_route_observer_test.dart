import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/route/route.dart';

void main() {
  group('FocusClearingRouteObserver', () {
    testWidgets('should clear the current focus when a route is pushed', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [
            FocusClearingRouteObserver(FocusManager.instance),
          ],
          home: Scaffold(body: TextField(focusNode: focusNode)),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);

      Navigator.of(
        tester.element(find.byType(TextField)),
      ).push(MaterialPageRoute<void>(builder: (_) => const Scaffold()));
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isFalse);
    });

    testWidgets('should clear the current focus when a route is replaced', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [
            FocusClearingRouteObserver(FocusManager.instance),
          ],
          home: Scaffold(body: TextField(focusNode: focusNode)),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(focusNode.hasFocus, isTrue);

      Navigator.of(tester.element(find.byType(TextField))).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const Scaffold()),
      );
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isFalse);
    });
  });
}
