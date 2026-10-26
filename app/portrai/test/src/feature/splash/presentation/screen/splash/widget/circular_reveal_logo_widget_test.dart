import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/splash/presentation/screen/splash/bloc/_bloc.dart';
import 'package:portrai/src/feature/splash/presentation/screen/splash/widget/circular_reveal_logo_widget.dart';

import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('CircularRevealLogoWidget', () {
    Widget buildWidget(SplashState state, VoidCallback onComplete) {
      return TestWidgetWrapper(
        child: CircularRevealLogoWidget(state: state, onComplete: onComplete),
      );
    }

    double logoOpacity(WidgetTester tester) {
      return tester
          .widget<Opacity>(
            find.ancestor(
              of: find.byType(Image),
              matching: find.byType(Opacity),
            ),
          )
          .opacity;
    }

    testWidgets('should draw the logo at the native splash size when built', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(SetUpProgressState.initial(), () {}));

      expect(
        tester.getSize(find.byType(Image)),
        const Size.square(CircularRevealLogoWidget.logoSize),
      );
      expect(logoOpacity(tester), 1);
    });

    testWidgets('should not complete when set up is still in progress', (
      tester,
    ) async {
      var completionCount = 0;

      await tester.pumpWidget(
        buildWidget(SetUpProgressState.initial(), () => completionCount++),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(completionCount, 0);
      expect(logoOpacity(tester), 1);
    });

    testWidgets('should fade the logo and complete once when set up '
        'completes', (tester) async {
      var completionCount = 0;
      void onComplete() => completionCount++;

      await tester.pumpWidget(
        buildWidget(SetUpProgressState.initial(), onComplete),
      );
      await tester.pumpWidget(
        buildWidget(const SetUpCompetedState(DesignSystem.beltane), onComplete),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(completionCount, 0);
      expect(logoOpacity(tester), inExclusiveRange(0, 1));

      await tester.pumpAndSettle();

      expect(completionCount, 1);
      expect(logoOpacity(tester), 0);
    });
  });
}
