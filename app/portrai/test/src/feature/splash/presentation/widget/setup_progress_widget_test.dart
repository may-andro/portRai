import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/splash/presentation/widget/setup_progress_widget.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  group('SetupProgressWidget', () {
    testWidgets(
      'should render the localized progress message and indicator value when built',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(child: SetupProgressWidget(0.5)),
        );

        expect(find.text('Setting up your experience...'), findsOneWidget);
        expect(
          tester
              .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .value,
          0.5,
        );
      },
    );
  });
}
