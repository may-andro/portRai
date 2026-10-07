import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/widget/content_widget.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/experience_list.dart';

import '../../../../../../../mock/feature/experience/presentation/screen/experiences/bloc/mock_experiences_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('Experiences ContentWidget', () {
    testWidgets('should render loading and track its impression when loading', (
      tester,
    ) async {
      const state = LoadingState();
      final bloc = MockExperiencesBloc()..stubState(state);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<ExperiencesBloc>.value(
            value: bloc,
            child: const ContentWidget(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DSLoadingWidget), findsOneWidget);
      verify(() => bloc.add(ViewStateVisibleEvent.loading())).called(1);
    });

    testWidgets('should render an error card when loading fails', (
      tester,
    ) async {
      const state = ErrorState(failure: ExperiencesNotFoundFailure());
      final bloc = MockExperiencesBloc()..stubState(state);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<ExperiencesBloc>.value(
            value: bloc,
            child: const ContentWidget(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DSErrorCardWidget), findsOneWidget);
    });

    testWidgets('should render an experience list when loading succeeds', (
      tester,
    ) async {
      const state = LoadedState(experiences: [], profile: null);
      final bloc = MockExperiencesBloc()..stubState(state);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<ExperiencesBloc>.value(
            value: bloc,
            child: const ContentWidget(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ExperienceListWidget), findsOneWidget);
      verify(() => bloc.add(ViewStateVisibleEvent.success())).called(1);
    });
  });
}
