import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/content_widget.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/widget/header/header_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/ai_image_gen/presentation/bloc/mock_ai_image_bloc.dart';
import '../../../../../../../mock/feature/portfolio/presentation/screen/portfolio/bloc/mock_portfolio_bloc.dart';
import '../../../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';
import '../../../../../../../mock/feature/profile/presentation/widget/professional_summary/bloc/mock_professional_summary_bloc.dart';
import '../../../../../../../util/package_info_setup.dart';
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
        verify(
          () => bloc.add(const ViewStateVisibleEvent('loading_content_view')),
        ).called(1);
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
        verify(
          () => bloc.add(const ViewStateVisibleEvent('error_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render the portfolio header and track its impression when loading succeeds',
      (tester) async {
        await appServiceLocator.reset();
        registerTestPackageInfo();
        addTearDown(appServiceLocator.reset);
        MockProfessionalSummaryBloc()
          ..stubLoadingState()
          ..registerFactory();
        MockAiImageBloc()
          ..stubLoadingState()
          ..registerFactory();
        final bloc = MockPortfolioBloc()
          ..stubState(LoadedState(portfolio: createPortfolioEntity()));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: ScreenFooterProviderWidget(
              footer: const Text('footer'),
              child: BlocProvider<PortfolioBloc>.value(
                value: bloc,
                child: const ContentWidget(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 6));
        await tester.pump(const Duration(seconds: 2));

        expect(find.byType(HeaderWidget), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('loaded_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should show the sections in the shared scroll view ending with the '
      'screen footer when loading succeeds',
      (tester) async {
        await appServiceLocator.reset();
        registerTestPackageInfo();
        addTearDown(appServiceLocator.reset);
        MockProfessionalSummaryBloc()
          ..stubLoadingState()
          ..registerFactory();
        MockAiImageBloc()
          ..stubLoadingState()
          ..registerFactory();
        final bloc = MockPortfolioBloc()
          ..stubState(LoadedState(portfolio: createPortfolioEntity()));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: ScreenFooterProviderWidget(
              footer: const Text('footer'),
              child: BlocProvider<PortfolioBloc>.value(
                value: bloc,
                child: const ContentWidget(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 6));
        await tester.pump(const Duration(seconds: 2));

        final scrollView = find.descendant(
          of: find.byType(ScreenContentWidget<PortfolioBloc, PortfolioState>),
          matching: find.byType(CustomScrollView),
        );
        expect(scrollView, findsOneWidget);
        expect(
          find.descendant(of: scrollView, matching: find.byType(HeaderWidget)),
          findsOneWidget,
        );
        final slivers = tester.widget<CustomScrollView>(scrollView).slivers;
        expect(
          find.descendant(
            of: find.byWidget(slivers.last, skipOffstage: false),
            matching: find.text('footer', skipOffstage: false),
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        expect(find.byType(FooterWidget), findsNothing);
      },
    );
  });
}
