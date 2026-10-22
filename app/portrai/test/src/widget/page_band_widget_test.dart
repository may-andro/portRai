import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/widget/page_band_widget.dart';

import '../../util/test_wrapper_widget.dart';

void main() {
  group('CountUpWidget', () {
    Future<void> pumpCountUp(WidgetTester tester, String value) {
      return tester.pumpWidget(
        TestWidgetWrapper(
          child: Builder(
            builder: (context) => CountUpWidget(
              value: value,
              style: context.typography.titleLarge,
              color: context.colorPalette.neutral.grey9,
            ),
          ),
        ),
      );
    }

    testWidgets('should count up to the number and keep its prefix and '
        'suffix when the value has a number', (tester) async {
      await pumpCountUp(tester, '~2.5k+');

      expect(find.text('~0.0k+'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('~2.5k+'), findsOneWidget);
    });

    testWidgets('should show the value as is when it has no number', (
      tester,
    ) async {
      await pumpCountUp(tester, 'Many');

      expect(find.text('Many'), findsOneWidget);
    });
  });
}
