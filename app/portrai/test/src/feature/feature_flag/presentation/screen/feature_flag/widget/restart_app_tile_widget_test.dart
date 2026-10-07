import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/restart_app_tile_widget.dart';

import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('RestartAppTileWidget', () {
    testWidgets(
      'should show the localized restart prompt when flags were manipulated',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(
            child: RestartAppTileWidget(hasManipulatedFlags: true),
          ),
        );

        final context = tester.element(find.byType(RestartAppTileWidget));
        expect(
          find.text(context.localizations.featureFlagRestartRequiredMessage),
          findsOneWidget,
        );
        expect(
          find.text(context.localizations.featureFlagRestartButton),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should hide the restart prompt when flags were not manipulated',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(
            child: RestartAppTileWidget(hasManipulatedFlags: false),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          tester
              .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
              .crossFadeState,
          CrossFadeState.showSecond,
        );
      },
    );
  });
}
