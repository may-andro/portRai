import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/project/project.dart';

import '../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  final first = createProjectEntity(id: 'first', title: 'Source first');
  final second = createProjectEntity(id: 'second', title: 'Source second');
  final third = createProjectEntity(
    id: 'third',
    title: 'Source third with a longer localized project title',
  );

  test('should snapshot source identity when the input list changes', () {
    final projects = [first, second];
    final widget = AssistantProjectCardsWidget(projects: projects);

    projects.clear();

    expect(widget.projects, [first, second]);
    expect(widget.projects.first, same(first));
    expect(() => widget.projects.add(third), throwsUnsupportedError);
    expect(() => widget.projects[0] = third, throwsUnsupportedError);
  });

  test('should reject excess projects when the resolver bound is exceeded', () {
    expect(
      () => AssistantProjectCardsWidget(
        projects: [
          first,
          second,
          third,
          createProjectEntity(id: 'fourth'),
        ],
      ),
      throwsArgumentError,
    );
  });

  test(
    'should reject duplicate IDs when distinct source records share an ID',
    () {
      expect(
        () => AssistantProjectCardsWidget(
          projects: [
            first,
            createProjectEntity(id: first.id),
          ],
        ),
        throwsArgumentError,
      );
    },
  );

  for (final id in ['', ' ', '\t\n']) {
    test(
      'should reject blank IDs when the source ID is ${id.length} characters',
      () {
        expect(
          () => AssistantProjectCardsWidget(
            projects: [createProjectEntity(id: id)],
          ),
          throwsArgumentError,
        );
      },
    );
  }

  Future<void> pumpCards(
    WidgetTester tester, {
    required List<ProjectEntity> projects,
    ValueChanged<ProjectEntity>? onProjectClick,
    double width = 600,
  }) => tester.pumpWidget(
    TestWidgetWrapper(
      child: Center(
        child: SizedBox(
          width: width,
          child: AssistantProjectCardsWidget(
            projects: projects,
            onProjectClick: onProjectClick,
          ),
        ),
      ),
    ),
  );

  testWidgets('should render nothing when the resolved list is empty', (
    tester,
  ) async {
    await pumpCards(tester, projects: []);

    expect(find.byType(DSCardWidget), findsNothing);
    expect(find.byType(DSTextWidget), findsNothing);
    expect(find.byType(InkWell), findsNothing);
  });

  for (final width in [220.0, 600.0]) {
    testWidgets(
      'should preserve source summaries and order when width is $width',
      (tester) async {
        await pumpCards(tester, projects: [third, first, second], width: width);

        expect(find.byType(DSCardWidget), findsNWidgets(3));
        expect(
          tester
              .widgetList<DSTextWidget>(find.byType(DSTextWidget))
              .map((w) => w.data),
          [
            third.title,
            third.description,
            first.title,
            first.description,
            second.title,
            second.description,
          ],
        );
        expect(
          tester.getTopLeft(find.text(third.title)).dy,
          lessThan(tester.getTopLeft(find.text(first.title)).dy),
        );
        expect(
          tester.getTopLeft(find.text(first.title)).dy,
          lessThan(tester.getTopLeft(find.text(second.title)).dy),
        );
        expect(find.text(first.longDescription), findsNothing);
        expect(find.byType(Image), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('should emit the exact source project when a card is clicked', (
    tester,
  ) async {
    final clicked = <ProjectEntity>[];
    await pumpCards(
      tester,
      projects: [second, first],
      onProjectClick: clicked.add,
    );

    expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));
    await tester.tap(find.text(first.title));

    expect(clicked, hasLength(1));
    expect(clicked.single, same(first));
    expect(clicked.single.website, first.website);
    expect(clicked.single.github, first.github);
  });

  testWidgets(
    'should omit actions and indicators when no callback is supplied',
    (tester) async {
      await pumpCards(tester, projects: [first]);

      expect(
        tester.widget<DSCardWidget>(find.byType(DSCardWidget)).onTap,
        isNull,
      );
      expect(find.byType(InkWell), findsNothing);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(find.byType(DSIconButtonWidget), findsNothing);
      expect(find.text(first.title), findsOneWidget);
    },
  );
}
