import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../util/test_wrapper_widget.dart';

const _pageHeight = 600.0;

Widget _scrollablePage({
  required ScrollController scrollController,
  required Widget animatedChild,
}) {
  return TestWidgetWrapper(
    brightness: Brightness.light,
    designSystem: DesignSystem.beltane,
    child: SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          SizedBox(height: 100, width: 100, child: animatedChild),
          const SizedBox(height: _pageHeight * 3),
        ],
      ),
    ),
  );
}

// Lets flutter_animate start its controller, which it does after a frame.
Future<void> _settleStart(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}

Future<void> _scrollAway(
  WidgetTester tester,
  ScrollController scrollController,
) async {
  scrollController.jumpTo(_pageHeight * 2);
  // Lays out the scroll, reports visibility, then rebuilds paused. A frame
  // the animation asked for before it paused still runs once.
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

void main() {
  group(DSOffscreenPauseWidget, () {
    testWidgets('should keep animating while on screen', (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _scrollablePage(
          scrollController: scrollController,
          animatedChild: DSOffscreenPauseWidget(
            child: const SizedBox.expand()
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 1.seconds),
          ),
        ),
      );
      await _settleStart(tester);

      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('should stop requesting frames once scrolled away', (
      tester,
    ) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        _scrollablePage(
          scrollController: scrollController,
          animatedChild: DSOffscreenPauseWidget(
            child: const SizedBox.expand()
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 1.seconds),
          ),
        ),
      );
      await _settleStart(tester);
      await _scrollAway(tester, scrollController);

      expect(tester.binding.hasScheduledFrame, isFalse);

      scrollController.jumpTo(0);
      await _settleStart(tester);

      expect(tester.binding.hasScheduledFrame, isTrue);
    });
  });

  group('looping backdrops', () {
    final backdrops = <String, Widget>{
      '$DSFestiveBackdropWidget': const DSFestiveBackdropWidget(),
      '$DSFloatingShapesBackgroundWidget':
          const DSFloatingShapesBackgroundWidget(color: Colors.blue),
      '$DSGradientBlobWidget': const DSGradientBlobWidget(
        size: 100,
        colors: [Colors.blue, Colors.transparent],
        scaleBegin: Offset(1, 1),
        scaleEnd: Offset(1.2, 1.2),
        duration: Duration(seconds: 1),
      ),
    };
    for (final MapEntry(key: name, value: backdrop) in backdrops.entries) {
      testWidgets('$name should stop requesting frames once scrolled away', (
        tester,
      ) async {
        final scrollController = ScrollController();
        addTearDown(scrollController.dispose);

        await tester.pumpWidget(
          _scrollablePage(
            scrollController: scrollController,
            animatedChild: backdrop,
          ),
        );
        await _settleStart(tester);
        expect(tester.binding.hasScheduledFrame, isTrue);

        await _scrollAway(tester, scrollController);

        expect(tester.binding.hasScheduledFrame, isFalse);
      });
    }
  });
}
