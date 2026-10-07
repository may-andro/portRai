import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/feature_flag/presentation/route/feature_flag_module_route.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/feature_flag_screen.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  group('FeatureFlagModuleRoute', () {
    test('should expose the expected name and path when accessed', () {
      expect(FeatureFlagModuleRoute.featureFlag.name, 'feature_flag');
      expect(FeatureFlagModuleRoute.featureFlag.path, '/feature-flag');
    });

    testWidgets(
      'should build the feature flag screen when the route builder is used',
      (tester) async {
        Widget? builtWidget;

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: Builder(
              builder: (context) {
                builtWidget = FeatureFlagModuleRoute.featureFlag.builder(
                  context,
                  null,
                  const <String, String>{},
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(builtWidget, isA<FeatureFlagScreen>());
      },
    );
  });
}
