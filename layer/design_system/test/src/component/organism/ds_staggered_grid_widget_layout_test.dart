import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DSStaggeredGridWidget', () {
    for (final (width, expected) in [
      (320.0, 10),
      (72.0, 9),
      (40.0, 5),
      (8.0, 1),
      (0.0, 1),
    ]) {
      test(
        'should fit $expected of 10 columns with 8 px gaps in $width px',
        () {
          expect(
            DSStaggeredGridWidget.fittingColumnCount(
              width: width,
              crossAxisCount: 10,
              crossAxisSpacing: 8,
            ),
            expected,
          );
        },
      );
    }

    for (final width in [60.0, 4.0, 0.0]) {
      testWidgets('should lay out without an error when only $width px '
          'wide', (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: DSStaggeredGridWidget(
                  crossAxisCount: 10,
                  itemCount: 12,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  itemBuilder: (_, _) => const SizedBox(height: 20),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
