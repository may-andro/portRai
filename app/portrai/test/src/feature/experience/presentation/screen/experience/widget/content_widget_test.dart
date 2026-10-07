import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/widget/content_widget.dart';

import '../../../../../../../mock/feature/experience/presentation/screen/experience/bloc/mock_experience_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('Experience ContentWidget', () {
    testWidgets(
      'should render a loading indicator and track its impression when loading',
      (tester) async {
        final bloc = MockExperienceBloc()..stubState(const LoadingState());

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ExperienceBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(() => bloc.add(ViewStateVisibleEvent.loading())).called(1);
      },
    );

    testWidgets(
      'should render an error card and track its impression when loading fails',
      (tester) async {
        final bloc = MockExperienceBloc()
          ..stubState(const ErrorState(failure: ExperienceNotFoundFailure()));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ExperienceBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        verify(() => bloc.add(ViewStateVisibleEvent.error())).called(1);
      },
    );
  });
}
