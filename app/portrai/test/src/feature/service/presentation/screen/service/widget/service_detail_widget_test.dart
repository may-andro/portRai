import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/_bloc.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../../mock/feature/call_booking/presentation/widget/book_call_entry/bloc/mock_book_call_entry_bloc.dart';
import '../../../../../../../mock/feature/service/presentation/screen/service/bloc/mock_service_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(() {
    resetTrackingImpressions();
    MockBookCallEntryBloc()
      ..stubAvailable(false)
      ..registerFactory();
  });

  tearDown(appServiceLocator.reset);

  const minimal = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );

  const full = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
    deliverables: ['Source code'],
    technologies: ['Flutter'],
    process: ['Discovery'],
    idealFor: ['Startups'],
    engagementTypes: ['Fixed price'],
    faq: [ServiceFaqEntity(question: 'How long?', answer: 'Weeks')],
  );

  Future<AppLocalizations> pump(
    WidgetTester tester,
    ServiceEntity service,
  ) async {
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<ServiceBloc>.value(
          value: MockServiceBloc()..stubState(const ServiceState()),
          child: ContentWidget(service: service),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    return AppLocalizations.of(tester.element(find.byType(ContentWidget)));
  }

  group('Book a call band', () {
    testWidgets('should offer a call about the service when booking is on', (
      tester,
    ) async {
      await appServiceLocator.reset();
      MockBookCallEntryBloc()
        ..stubAvailable(true)
        ..registerFactory();

      final localizations = await pump(tester, full);

      expect(find.text(localizations.bookCallServiceTitle), findsOneWidget);
      expect(find.text(localizations.bookCall), findsOneWidget);
    });

    testWidgets('should not offer a call when booking is off', (tester) async {
      final localizations = await pump(tester, full);

      expect(find.text(localizations.bookCallServiceTitle), findsNothing);
    });
  });

  group('Service details', () {
    testWidgets(
      'should wrap long audience chips within the screen width on mobile',
      (tester) async {
        const mobileWidth = 390.0;
        tester.view.physicalSize = const Size(mobileWidth, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        const serviceWithLongAudiences = ServiceEntity(
          image: 'service.png',
          title: 'App Development',
          description: 'Beautiful apps',
          detail: 'Detailed service description',
          idealFor: [
            'Apps that must connect to APIs, Firebase or GraphQL backends',
            'Products that need real-time data such as live maps or order tracking',
          ],
        );
        await pump(tester, serviceWithLongAudiences);

        for (final audience in serviceWithLongAudiences.idealFor) {
          expect(find.text(audience), findsOneWidget);
          expect(
            tester.getRect(find.text(audience)).right,
            lessThanOrEqualTo(mobileWidth),
          );
        }
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('should hide optional sections when the lists are empty', (
      tester,
    ) async {
      final l10n = await pump(tester, minimal);

      expect(find.text(minimal.detail), findsOneWidget);
      expect(find.text(l10n.serviceDetailDeliverables), findsNothing);
      expect(find.text(l10n.serviceDetailProcess), findsNothing);
      expect(find.text(l10n.serviceDetailTechnologies), findsNothing);
      expect(find.text(l10n.serviceDetailIdealFor), findsNothing);
      expect(find.text(l10n.serviceDetailEngagement), findsNothing);
      expect(find.text(l10n.serviceDetailFaq), findsNothing);
    });

    testWidgets('should show every section when the service has all data', (
      tester,
    ) async {
      final l10n = await pump(tester, full);

      expect(find.text(l10n.serviceDetailDeliverables), findsOneWidget);
      expect(find.text(l10n.serviceDetailProcess), findsOneWidget);
      expect(find.text(l10n.serviceDetailTechnologies), findsOneWidget);
      expect(find.text(l10n.serviceDetailIdealFor), findsOneWidget);
      expect(find.text(l10n.serviceDetailEngagement), findsOneWidget);
      expect(find.text(l10n.serviceDetailFaq), findsOneWidget);
      expect(find.text('How long?'), findsOneWidget);
    });
  });
}
