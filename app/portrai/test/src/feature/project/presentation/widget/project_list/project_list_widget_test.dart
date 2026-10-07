import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/project_list_widget.dart';

import '../../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('ProjectListWidget', () {
    testWidgets(
      'should render the trailing emoji and use the project ID for the hero tag',
      (tester) async {
        final project = createProjectEntity();

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: TickerMode(
              enabled: false,
              child: ProjectListWidget(projects: [project], isVisible: false),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('🚀'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Hero && widget.tag == 'project-image-port-rai',
          ),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
      },
    );
  });
}
