import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/widget/intro_widget.dart';

import '../../../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('IntroWidget', () {
    testWidgets(
      'should render the title and use the project ID for the hero tag',
      (tester) async {
        final project = createProjectEntity();

        await tester.pumpWidget(
          TestWidgetWrapper(child: IntroWidget(project: project)),
        );
        await tester.pump(const Duration(seconds: 3));

        expect(find.text(project.title), findsOneWidget);
        expect(find.text(project.description), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Hero && widget.tag == 'project-image-port-rai',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
