import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/search_widget.dart';

import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('SearchWidget', () {
    testWidgets('should render the localized hint when the field is shown', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SearchWidget(
            searchController: controller,
            searchQuery: '',
            onSearch: (_) {},
          ),
        ),
      );

      final context = tester.element(find.byType(SearchWidget));
      expect(
        find.text(context.localizations.featureFlagSearchHint),
        findsOneWidget,
      );
    });

    testWidgets('should clear the query when the clear button is tapped', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'services');
      addTearDown(controller.dispose);
      String? query;

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SearchWidget(
            searchController: controller,
            searchQuery: 'services',
            onSearch: (value) => query = value,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(query, '');
    });
  });
}
