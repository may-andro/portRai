import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/developer_mode/developer_mode.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  group('DeveloperMenuModuleRoute', () {
    test('should expose the expected name and path when accessed', () {
      expect(DeveloperMenuModuleRoute.developerMenu.name, 'developer_menu');
      expect(DeveloperMenuModuleRoute.developerMenu.path, '/developer-menu');
    });

    testWidgets(
      'should build the developer menu screen when the route builder is used',
      (tester) async {
        Widget? builtWidget;

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: Builder(
              builder: (context) {
                builtWidget = DeveloperMenuModuleRoute.developerMenu.builder(
                  context,
                  null,
                  const {},
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(builtWidget, isA<DeveloperMenuScreen>());
      },
    );
  });
}
