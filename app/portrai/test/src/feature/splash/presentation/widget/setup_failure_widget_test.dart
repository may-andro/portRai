import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/splash/presentation/widget/setup_failure_widget.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  group('SetupFailureWidget', () {
    testWidgets(
      'should render the localized failure title and details when descriptive mode is enabled',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(
            child: SetupFailureWidget(
              'missing dependency',
              isDescriptiveMode: true,
            ),
          ),
        );

        expect(find.text('Setup Failed'), findsOneWidget);
        expect(find.text('missing dependency'), findsOneWidget);
        expect(find.byType(RichText), findsWidgets);
      },
    );

    testWidgets(
      'should show a localized snack bar when the support link is tapped',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(child: SetupFailureWidget('boom')),
        );

        final richTextFinder = find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              (widget.text as TextSpan).toPlainText().contains(
                'contact support',
              ),
        );
        final richText = tester.widget<RichText>(richTextFinder);
        final textSpan = richText.text as TextSpan;
        final supportSpan = textSpan.children!.last as TextSpan;

        (supportSpan.recognizer! as TapGestureRecognizer).onTap!();
        await tester.pump();

        expect(find.text('This feature is not yet developed'), findsOneWidget);
      },
    );
  });
}
