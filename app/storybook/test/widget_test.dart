import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:storybook/main.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  testWidgets('should render Widgetbook', (WidgetTester tester) async {
    // Set a large screen size to avoid overflow issues
    await tester.binding.setSurfaceSize(const Size(1920, 1080));

    await tester.pumpWidget(const StorybookApp());

    expect(find.byType(Widgetbook), findsOneWidget);

    // Reset surface size
    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
