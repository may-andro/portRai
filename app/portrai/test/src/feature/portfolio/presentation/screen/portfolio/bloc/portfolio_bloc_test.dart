import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/portfolio/domain/use_case/mock_get_portfolio_use_case.dart';
import '../../../../../../../mock/feature/portfolio/presentation/screen/portfolio/tracking/mock_portfolio_tracking_delegate.dart';
import '../../../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';

void main() {
  final portfolio = createPortfolioEntity();

  group('PortfolioBloc', () {
    late MockGetPortfolioUseCase getPortfolioUseCase;
    late MockPortfolioTrackingDelegate trackingDelegate;

    PortfolioBloc buildBloc() =>
        PortfolioBloc(getPortfolioUseCase, trackingDelegate);

    setUp(() {
      getPortfolioUseCase = MockGetPortfolioUseCase();
      trackingDelegate = MockPortfolioTrackingDelegate();
    });

    blocTest<PortfolioBloc, PortfolioState>(
      'should emit loading and loaded when loading the portfolio succeeds',
      setUp: () => getPortfolioUseCase.stubCall(
        Right<GetPortfolioFailure, PortfolioEntity>(portfolio),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadPortfolioEvent()),
      expect: () => [const LoadingState(), LoadedState(portfolio: portfolio)],
      verify: (_) => verify(() => getPortfolioUseCase()).called(1),
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'should emit loading and error when loading the portfolio fails',
      setUp: () => getPortfolioUseCase.stubCall(
        const Left<GetPortfolioFailure, PortfolioEntity>(
          GetPortfolioNotFoundFailure(),
        ),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadPortfolioEvent()),
      expect: () => [
        const LoadingState(),
        isA<ErrorState>().having(
          (state) => state.failure,
          'failure',
          isA<GetPortfolioNotFoundFailure>(),
        ),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'should emit an unknown failure when the use case throws unexpectedly',
      setUp: () {
        when(() => getPortfolioUseCase()).thenThrow(Exception('boom'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadPortfolioEvent()),
      expect: () => [const LoadingState(), const ErrorState(UnknownFailure())],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'should update the selected section and track header and drawer navigation when loaded',
      build: buildBloc,
      seed: () => LoadedState(portfolio: portfolio),
      act: (bloc) {
        bloc.add(
          const SectionNavigationEvent(
            sectionIndex: 1,
            sectionId: 'portfolio_projects_section',
            source: NavigationSource.header,
          ),
        );
        bloc.add(
          const SectionNavigationEvent(
            sectionIndex: 2,
            sectionId: 'portfolio_services_section',
            source: NavigationSource.drawer,
          ),
        );
      },
      expect: () => [
        LoadedState(
          portfolio: portfolio,
          selectedSectionIndex: 1,
          lastNavigationSource: NavigationSource.header,
        ),
        LoadedState(
          portfolio: portfolio,
          selectedSectionIndex: 2,
          lastNavigationSource: NavigationSource.drawer,
        ),
      ],
      verify: (_) {
        verify(
          () => trackingDelegate.trackTabItemSelection(
            'portfolio_projects_section',
          ),
        ).called(1);
        verify(
          () => trackingDelegate.trackDrawerItemSelection(
            'portfolio_services_section',
          ),
        ).called(1);
      },
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'should update the selected section without click tracking when scrolling to a section',
      build: buildBloc,
      seed: () => LoadedState(portfolio: portfolio),
      act: (bloc) => bloc.add(
        const SectionNavigationEvent(
          sectionIndex: 3,
          sectionId: 'portfolio_experience_section',
          source: NavigationSource.scroll,
        ),
      ),
      expect: () => [
        LoadedState(
          portfolio: portfolio,
          selectedSectionIndex: 3,
          lastNavigationSource: NavigationSource.scroll,
        ),
      ],
      verify: (_) {
        verifyNever(() => trackingDelegate.trackTabItemSelection(any()));
        verifyNever(() => trackingDelegate.trackDrawerItemSelection(any()));
      },
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'should track screen views drawer changes and content impressions when visible events arrive',
      build: buildBloc,
      act: (bloc) {
        bloc.add(const ScreenVisibleEvent());
        bloc.add(const DrawerClickEvent(true));
        bloc.add(const DrawerClickEvent(false));
        bloc.add(ViewStateVisibleEvent.loading());
        bloc.add(ViewStateVisibleEvent.success());
        bloc.add(ViewStateVisibleEvent.error());
        bloc.add(const SectionVisibleEvent('portfolio_projects_section'));
      },
      expect: () => const <PortfolioState>[],
      verify: (_) {
        verify(() => trackingDelegate.trackScreenView()).called(1);
        verify(() => trackingDelegate.trackDrawerOpen()).called(1);
        verify(() => trackingDelegate.trackDrawerClose()).called(1);
        verify(
          () => trackingDelegate.trackViewEvent('loading_content_view'),
        ).called(1);
        verify(
          () => trackingDelegate.trackViewEvent('loaded_content_view'),
        ).called(1);
        verify(
          () => trackingDelegate.trackViewEvent('error_content_view'),
        ).called(1);
        verify(
          () => trackingDelegate.trackViewEvent('portfolio_projects_section'),
        ).called(1);
      },
    );
  });
}
