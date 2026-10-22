import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/widget/content_widget.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/_widget.dart';

import '../../../../../../../mock/feature/expertise/presentation/screen/expertises/bloc/mock_expertises_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  Future<void> pumpContent(WidgetTester tester, MockExpertisesBloc bloc) async {
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<ExpertisesBloc>.value(
          value: bloc,
          child: const ContentWidget(),
        ),
      ),
    );
    await tester.pump();
  }

  group('Expertises ContentWidget', () {
    testWidgets('should render loading and track its impression when loading', (
      tester,
    ) async {
      final bloc = MockExpertisesBloc()..stubState(const LoadingState());

      await pumpContent(tester, bloc);

      expect(find.byType(DSLoadingWidget), findsOneWidget);
      verify(
        () => bloc.add(const ViewStateVisibleEvent('loading_content_view')),
      ).called(1);
    });

    testWidgets(
      'should render an error card and track its impression when loading fails',
      (tester) async {
        final bloc = MockExpertisesBloc()
          ..stubState(const ErrorState(failure: ExpertiseNotFoundFailure()));

        await pumpContent(tester, bloc);

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('error_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render an expertise list and track its impression when loading succeeds',
      (tester) async {
        final bloc = MockExpertisesBloc()
          ..stubState(const LoadedState(expertises: [], profile: null));

        await pumpContent(tester, bloc);

        expect(find.byType(ExpertiseListWidget), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('loaded_content_view')),
        ).called(1);
      },
    );
  });
}
