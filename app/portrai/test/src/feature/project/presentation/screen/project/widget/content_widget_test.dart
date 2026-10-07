import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/extension/_extension.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/widget/content_widget.dart';

import '../../../../../../../mock/feature/project/presentation/screen/project/bloc/mock_project_bloc.dart';
import '../../../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('Project ContentWidget', () {
    testWidgets(
      'should render a loading indicator and track its impression when loading',
      (tester) async {
        final bloc = MockProjectBloc()..stubState(const LoadingState());

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ProjectBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(
          () => bloc.add(const LoadingContentViewVisibleEvent()),
        ).called(1);
      },
    );

    testWidgets(
      'should render intro content and track its impression when loaded',
      (tester) async {
        final project = createProjectEntity();
        final bloc = MockProjectBloc()
          ..stubState(
            LoadedState(project: project, sections: project.sections),
          );

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ProjectBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('A polished portfolio app'), findsOneWidget);
        expect(find.text('Overview'), findsWidgets);
        verify(
          () => bloc.add(const SuccessContentViewVisibleEvent()),
        ).called(1);
      },
    );
  });
}
