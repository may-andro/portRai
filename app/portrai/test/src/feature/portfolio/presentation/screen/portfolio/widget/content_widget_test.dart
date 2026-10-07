import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/content_widget.dart';

import '../../../../../../../mock/feature/portfolio/presentation/screen/portfolio/bloc/mock_portfolio_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('Portfolio ContentWidget', () {
    testWidgets(
      'should render a loading indicator and track its impression when loading',
      (tester) async {
        final bloc = MockPortfolioBloc()..stubState(const LoadingState());

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<PortfolioBloc>.value(
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
        final bloc = MockPortfolioBloc()
          ..stubState(const ErrorState(GetPortfolioNotFoundFailure()));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<PortfolioBloc>.value(
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
