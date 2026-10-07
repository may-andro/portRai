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
        expect(find.text(testimonial.position), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
      },
    );
  });
}
