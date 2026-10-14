import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import '../../../../util/test_wrapper_widget.dart';

void main() {
  Widget buildSubject(DSLoadingStyle style) => TestWidgetWrapper(
    brightness: Brightness.light,
    designSystem: DesignSystem.values.first,
    child: DSLoadingWidget(size: 40, style: style),
  );

  testWidgets('should render the lottie loader when style is lottie', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(DSLoadingStyle.lottie));

    expect(find.byType(LottieBuilder), findsOneWidget);
  });

  testWidgets('should not render a lottie loader when style is dots', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(DSLoadingStyle.dots));

    expect(find.byType(LottieBuilder), findsNothing);
  });
}
