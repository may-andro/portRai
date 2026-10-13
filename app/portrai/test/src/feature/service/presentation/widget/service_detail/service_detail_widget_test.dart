import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_detail/service_detail.dart';

import '../../../../../../util/test_wrapper_widget.dart';

void main() {
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
      TestWidgetWrapper(child: ServiceDetailWidget(service: service)),
    );
    await tester.pump(const Duration(seconds: 1));
    return AppLocalizations.of(
      tester.element(find.byType(ServiceDetailWidget)),
    );
  }

  group('ServiceDetailWidget', () {
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
      expect(
        find.text(l10n.serviceDetailIdealFor.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(l10n.serviceDetailEngagement), findsOneWidget);
      expect(find.text(l10n.serviceDetailFaq), findsOneWidget);
      expect(find.text('How long?'), findsOneWidget);
    });
  });
}
