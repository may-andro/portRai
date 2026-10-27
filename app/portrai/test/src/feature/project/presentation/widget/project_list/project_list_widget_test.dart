import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/project_list_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/project/presentation/widget/project_list/bloc/mock_project_list_bloc.dart';
import '../../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  late MockProjectListBloc bloc;

  setUp(() async {
    await appServiceLocator.reset();
    bloc = MockProjectListBloc()
      ..stubState()
      ..registerFactory();
  });

  tearDown(() => appServiceLocator.reset());

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

    testWidgets('should track the tap and open the project when a project is '
        'tapped', (tester) async {
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

      await tester.tap(find.text('🚀'));
      await tester.pump();

      verify(
        () => bloc.add(
          ProjectClickEvent(label: 'project_card', projectId: project.id),
        ),
      ).called(1);
      // No router in the test wrapper, so opening the project throws.
      expect(tester.takeException(), isNotNull);

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
