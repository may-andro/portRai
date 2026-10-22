import 'package:design_system/assets/assets.gen.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import '../../../../util/test_wrapper_widget.dart';

void main() {
  Widget buildSubject(DSColor color) => TestWidgetWrapper(
    brightness: Brightness.light,
    designSystem: DesignSystem.values.first,
    child: DSLottieWidget(
      asset: Assets.lottie.binoculars,
      size: 48,
      // A new list on every build, as callers create it in their build.
      colorOverrides: [
        DSLottieColorOverride(keyPath: const ['**'], color: color),
      ],
    ),
  );

  LottieDelegates? delegatesOf(WidgetTester tester) =>
      tester.widget<LottieBuilder>(find.byType(LottieBuilder)).delegates;

  testWidgets('should keep the same delegates when rebuilt with equal color '
      'overrides', (tester) async {
    await tester.pumpWidget(buildSubject(const DSColor(0xFF112233)));
    final firstDelegates = delegatesOf(tester);

    await tester.pumpWidget(buildSubject(const DSColor(0xFF112233)));

    expect(delegatesOf(tester), same(firstDelegates));
  });

  testWidgets('should build new delegates when the color overrides change', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const DSColor(0xFF112233)));
    final firstDelegates = delegatesOf(tester);

    await tester.pumpWidget(buildSubject(const DSColor(0xFF445566)));

    expect(delegatesOf(tester), isNot(same(firstDelegates)));
    expect(delegatesOf(tester)!.values!.first.value, const Color(0xFF445566));
  });
}
