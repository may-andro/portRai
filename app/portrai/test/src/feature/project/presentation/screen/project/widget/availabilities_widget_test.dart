import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/widget/availabilities_widget.dart';

import '../../../../../../../mock/feature/project/presentation/screen/project/bloc/mock_project_bloc.dart';
import '../../../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('AvailabilitiesWidget', () {
    testWidgets(
      'should render localized availability buttons and dispatch open URL events when tapped',
      (tester) async {
        final bloc = MockProjectBloc()..stubState(const LoadingState());
        final project = createProjectEntity();

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ProjectBloc>.value(
              value: bloc,
              child: AvailabilitiesWidget(project: project),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('GitHub'), findsOneWidget);
        expect(find.text('Website'), findsOneWidget);
        expect(find.text('App Store'), findsOneWidget);
        expect(find.text('Play Store'), findsOneWidget);

        await tester.tap(find.text('GitHub'));
        await tester.pump();

        verify(
          () => bloc.add(
            const OpenExternalUrlEvent(
              url: 'https://github.com/example/portrai',
              label: 'GitHub',
            ),
          ),
        ).called(1);
      },
    );

    testWidgets('should only render buttons for non-null availability links', (
      tester,
    ) async {
      final bloc = MockProjectBloc()..stubState(const LoadingState());
      final project = createProjectEntity(
        website: null,
        appStore: null,
        playStore: null,
      );

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<ProjectBloc>.value(
            value: bloc,
            child: AvailabilitiesWidget(project: project),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('Website'), findsNothing);
      expect(find.text('App Store'), findsNothing);
      expect(find.text('Play Store'), findsNothing);
    });
  });
}
