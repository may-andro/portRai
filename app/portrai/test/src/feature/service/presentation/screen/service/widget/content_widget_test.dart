import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/_bloc.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/widget/_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/service/presentation/screen/service/bloc/mock_service_bloc.dart';
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

  Future<void> pumpContent(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: ScreenFooterProviderWidget(
          footer: const Text('footer'),
          child: BlocProvider<ServiceBloc>.value(
            value: MockServiceBloc()..stubState(const ServiceState()),
            child: const ContentWidget(service: service),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  group('Service ContentWidget', () {
    for (final entry in {
      'mobile': const Size(390, 844),
      'desktop': const Size(1440, 900),
    }.entries) {
      testWidgets(
        'should render the service details without errors when on ${entry.key}',
        (tester) async {
          await pumpContent(tester, entry.value);

          expect(find.text(service.detail), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'should end the shared scroll view with the provided footer when shown',
      (tester) async {
        await pumpContent(tester, const Size(390, 844));

        final scrollView = find.byType(CustomScrollView);
        expect(scrollView, findsOneWidget);
        expect(
          find.descendant(of: scrollView, matching: find.text(service.detail)),
          findsOneWidget,
        );
        await tester.scrollUntilVisible(
          find.text('footer', skipOffstage: false),
          500,
          scrollable: find
              .descendant(of: scrollView, matching: find.byType(Scrollable))
              .first,
        );
        expect(
          find.descendant(
            of: scrollView,
            matching: find.text('footer', skipOffstage: false),
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        expect(
          tester.getTopLeft(find.text('footer', skipOffstage: false)).dy,
          greaterThanOrEqualTo(
            tester.getBottomLeft(find.text(service.detail)).dy,
          ),
        );
        expect(find.byType(FooterWidget), findsNothing);
      },
    );
  });
}
