import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/dto/_dto.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/extension/_extension.dart';

import '../../../../../../../mock/feature/project/presentation/screen/project/bloc/mock_project_bloc.dart';
import '../../../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  final project = createProjectEntity();

  Future<void> pumpSections(WidgetTester tester) {
    final sections = project.sections
        .whereType<ScrollableProjectSectionDTO>()
        .toList();
    final bloc = MockProjectBloc()..stubState(const LoadingState());
    return tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<ProjectBloc>.value(
          value: bloc,
          child: Builder(
            builder: (context) {
              return SingleChildScrollView(
                child: Column(
                  children: sections
                      .map((section) => section.buildWidget(context))
                      .toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  group('ProjectSectionDTO', () {
    setUp(resetTrackingImpressions);

    testWidgets('should render localized titles for all scrollable sections', (
      tester,
    ) async {
      await pumpSections(tester);

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Technologies'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Key Features'), findsOneWidget);
      expect(find.text('Available On'), findsOneWidget);
    });

    testWidgets(
      'should resolve section titles from localizations when requested',
      (tester) async {
        late List<String> titles;
        final sections = project.sections
            .whereType<ScrollableProjectSectionDTO>()
            .toList();

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: Builder(
              builder: (context) {
                titles = sections
                    .map((section) => section.getTitle(context))
                    .toList();
                return const SizedBox();
              },
            ),
          ),
        );

        expect(titles, [
          'Overview',
          'Technologies',
          'Achievements',
          'Key Features',
          'Available On',
        ]);
      },
    );
  });
}
