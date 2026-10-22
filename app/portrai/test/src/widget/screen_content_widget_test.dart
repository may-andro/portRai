import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';
import 'package:tracking/tracking.dart';
import 'package:use_case/use_case.dart';

import '../../mock/widget/mock_screen_content_cubit.dart';
import '../../util/test_wrapper_widget.dart';
import '../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('ScreenContentWidget', () {
    Future<List<String>> pumpScreenContent(
      WidgetTester tester,
      MockScreenContentCubit cubit,
    ) async {
      final visibleLabels = <String>[];
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<MockScreenContentCubit>.value(
            value: cubit,
            child: ScreenContentWidget<MockScreenContentCubit, FakeScreenState>(
              impressionPrefix: 'test',
              contentOf: (state) => switch (state) {
                FakeLoadingState() => const ScreenLoadingContent(),
                FakeErrorState() => const ScreenErrorContent(UnknownFailure()),
                FakeLoadedState() => const ScreenLoadedContent(
                  Text('loaded content'),
                ),
              },
              onContentVisible: (content) =>
                  visibleLabels.add(content.trackingLabel),
            ),
          ),
        ),
      );
      await tester.pump();
      return visibleLabels;
    }

    testWidgets(
      'should show the lottie loading indicator and report it when loading',
      (tester) async {
        final cubit = MockScreenContentCubit()
          ..stubStates(const FakeLoadingState());

        final visibleLabels = await pumpScreenContent(tester, cubit);

        final loadingWidget = tester.widget<DSLoadingWidget>(
          find.byType(DSLoadingWidget),
        );
        expect(loadingWidget.style, DSLoadingStyle.lottie);
        expect(visibleLabels, ['loading_content_view']);
      },
    );

    testWidgets(
      'should show the translated failure in an error card and report it '
      'when the content is an error',
      (tester) async {
        final cubit = MockScreenContentCubit()
          ..stubStates(const FakeErrorState());

        final visibleLabels = await pumpScreenContent(tester, cubit);

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        expect(find.text('Something went wrong. Please try again'), findsOne);
        expect(visibleLabels, ['error_content_view']);
      },
    );

    testWidgets('should show the loaded child and report it when loaded', (
      tester,
    ) async {
      final cubit = MockScreenContentCubit()
        ..stubStates(const FakeLoadedState());

      final visibleLabels = await pumpScreenContent(tester, cubit);

      expect(find.text('loaded content'), findsOneWidget);
      expect(visibleLabels, ['loaded_content_view']);
    });

    testWidgets(
      'should report the loaded content when the state changes from loading '
      'to loaded',
      (tester) async {
        final cubit = MockScreenContentCubit()
          ..stubStates(const FakeLoadingState(), [const FakeLoadedState()]);

        final visibleLabels = await pumpScreenContent(tester, cubit);
        await tester.pump();

        expect(find.text('loaded content'), findsOneWidget);
        expect(visibleLabels, ['loading_content_view', 'loaded_content_view']);
      },
    );

    testWidgets(
      'should show the loaded child without an impression detector when no '
      'content callback is given',
      (tester) async {
        final cubit = MockScreenContentCubit()
          ..stubStates(const FakeLoadedState());

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<MockScreenContentCubit>.value(
              value: cubit,
              child:
                  ScreenContentWidget<MockScreenContentCubit, FakeScreenState>(
                    contentOf: (_) =>
                        const ScreenLoadedContent(Text('loaded content')),
                  ),
            ),
          ),
        );

        expect(find.text('loaded content'), findsOneWidget);
        expect(find.byType(TrackingImpressionDetectorWidget), findsNothing);
      },
    );

    testWidgets('should call onRetry when the error card retry is tapped', (
      tester,
    ) async {
      var retryCount = 0;
      final cubit = MockScreenContentCubit()
        ..stubStates(const FakeErrorState());

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<MockScreenContentCubit>.value(
            value: cubit,
            child: ScreenContentWidget<MockScreenContentCubit, FakeScreenState>(
              contentOf: (_) => ScreenErrorContent(
                const UnknownFailure(),
                onRetry: () => retryCount++,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(DSButtonWidget));

      expect(retryCount, 1);
    });
  });
}
