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
              child: ProjectListWidget(
                projects: [project],
                isVisible: false,
                onClicked: _ignoreClick,
              ),
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

    testWidgets('should report the tapped project when a project is tapped', (
      tester,
    ) async {
      final project = createProjectEntity();
      final clickedProjects = <Object>[];

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: TickerMode(
            enabled: false,
            child: ProjectListWidget(
              projects: [project],
              isVisible: false,
              onClicked: clickedProjects.add,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('🚀'));
      await tester.pump();

      expect(clickedProjects, [project]);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });

    for (final entry in const {
      'mobile': Size(390, 844),
      'tablet': Size(820, 1180),
      'desktop': Size(1440, 900),
    }.entries) {
      testWidgets(
        'should render every project without errors when on ${entry.key}',
        (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            TestWidgetWrapper(
              child: SingleChildScrollView(
                child: ProjectListWidget(
                  projects: [
                    createProjectEntity(id: 'a'),
                    createProjectEntity(id: 'b'),
                    createProjectEntity(id: 'c'),
                  ],
                  isVisible: true,
                  onClicked: _ignoreClick,
                ),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 2));

          expect(find.text('🚀'), findsNWidgets(3));
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}

void _ignoreClick(Object _) {}
