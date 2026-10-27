import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  testWidgets('should report the tap when the card is tapped', (tester) async {
    var clickCount = 0;
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: Scaffold(
          body: JobOpeningsCardWidget(onClicked: () => clickCount++),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Job openings'));
    await tester.pumpAndSettle();

    expect(clickCount, 1);
    expect(tester.takeException(), isNull);
  });
}
