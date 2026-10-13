import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/widget/_widget.dart';

import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  const service = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );

  group('Service ContentWidget', () {
    for (final entry in {
      'mobile': const Size(390, 844),
      'desktop': const Size(1440, 900),
    }.entries) {
      testWidgets(
        'should render the service details without errors when on ${entry.key}',
        (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            const TestWidgetWrapper(child: ContentWidget(service: service)),
          );
          await tester.pump(const Duration(seconds: 1));

          expect(find.text(service.detail), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
