import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/service_list_widget.dart';

import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  const service = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );

  group('ServiceListWidget', () {
    testWidgets('should render the service summary when built', (tester) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: ServiceListWidget(services: [service], isVisible: true),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(service.title), findsOneWidget);
      expect(find.byType(DSSpotlightCardWidget), findsOneWidget);
      expect(find.byType(DSNetworkImageWidget), findsOneWidget);
    });

    testWidgets('should navigate to the service screen when a card is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: ServiceListWidget(services: [service], isVisible: true),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(DSSpotlightCardWidget));
      await tester.pump(const Duration(seconds: 1));

      // No router in the test wrapper, so an attempted navigation throws.
      expect(tester.takeException(), isNotNull);
    });

    testWidgets('should limit the cards when visibleItemsCount is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: ServiceListWidget(
            services: [service, service, service],
            isVisible: true,
            visibleItemsCount: 2,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(DSSpotlightCardWidget), findsNWidgets(2));
    });
  });
}
