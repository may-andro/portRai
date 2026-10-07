import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/portfolio/portfolio.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  group('PortfolioModuleRoute', () {
    test('should expose the expected name and path when accessed', () {
      expect(PortfolioModuleRoute.portfolio.name, '/');
      expect(PortfolioModuleRoute.portfolio.path, '/');
    });

    testWidgets(
      'should build the portfolio screen when the route builder is used',
      (tester) async {
        Widget? builtWidget;

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: Builder(
              builder: (context) {
                builtWidget = PortfolioModuleRoute.portfolio.builder(
                  context,
                  null,
                  const {},
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(builtWidget, isA<PortfolioScreen>());
      },
    );
  });
}
