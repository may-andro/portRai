import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../util/test_wrapper_widget.dart';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('should call onTap when it is tapped', (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      TestWidgetWrapper(
        brightness: Brightness.light,
        designSystem: DesignSystem.values.first,
        child: Center(
          child: DSBrandIconButtonWidget(
            brand: DSBrandIcon.github,
            onTap: () => tapCount++,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(DSBrandIconButtonWidget));

    expect(tapCount, 1);
  });

  testWidgets('should loop the animation by default when it is shown', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestWidgetWrapper(
        brightness: Brightness.light,
        designSystem: DesignSystem.values.first,
        child: Center(
          child: DSBrandIconButtonWidget(
            brand: DSBrandIcon.linkedin,
            onTap: () {},
          ),
        ),
      ),
    );

    final widget = tester.widget<DSBrandIconWidget>(
      find.byType(DSBrandIconWidget),
    );
    expect(widget.playback, DSLottiePlayback.loop);
  });
}
