import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/route/route.dart';

import '../../../util/test_wrapper_widget.dart';

void main() {
  group('RouteNotFoundScreen', () {
    testWidgets('should render the localized empty route content when shown', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestWidgetWrapper(child: RouteNotFoundScreen()),
      );

      final context = tester.element(find.byType(RouteNotFoundScreen));
      expect(
        find.text(context.localizations.routeNotFoundTitle),
        findsOneWidget,
      );
      expect(
        find.text(context.localizations.routeNotFoundMessage),
        findsOneWidget,
      );
      expect(
        find.text(context.localizations.routeNotFoundButton),
        findsOneWidget,
      );
    });
  });
}
