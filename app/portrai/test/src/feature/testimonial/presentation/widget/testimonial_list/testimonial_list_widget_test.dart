import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/testimonial/presentation/widget/testimonial_list/testimonial_list_widget.dart';

import '../../../../../../mock/feature/testimonial/test_data/testimonial_test_data.dart';
import '../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('TestimonialListWidget', () {
    testWidgets(
      'should render the testimonial text and author details when built',
      (tester) async {
        final testimonial = createTestimonialEntity();

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: TickerMode(
              enabled: false,
              child: TestimonialListWidget(
                testimonials: [testimonial],
                isVisible: false,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text(testimonial.testimonial), findsOneWidget);
        expect(find.text(testimonial.name), findsOneWidget);
        expect(
          find.text('${testimonial.position} · ${testimonial.company}'),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
      },
    );

    testWidgets(
      'should render only the first two testimonials when more are provided',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1440, 1400);
        addTearDown(tester.view.reset);
        final testimonials = [
          for (var i = 0; i < 4; i++)
            createTestimonialEntity(id: 'id$i', testimonial: 'Quote $i'),
        ];

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: TickerMode(
              enabled: false,
              child: SingleChildScrollView(
                child: TestimonialListWidget(
                  testimonials: testimonials,
                  isVisible: false,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Quote 0'), findsOneWidget);
        expect(find.text('Quote 1'), findsOneWidget);
        expect(find.text('Quote 2'), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
      },
    );

    testWidgets('should list every testimonial when showAll is called', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 2400);
      addTearDown(tester.view.reset);
      final testimonials = [
        for (var i = 0; i < 4; i++)
          createTestimonialEntity(id: 'id$i', testimonial: 'Quote $i'),
      ];

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  TestimonialListWidget.showAll(context, testimonials),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Quote 0'), findsOneWidget);
      expect(find.text('Quote 3'), findsOneWidget);
    });
  });
}
