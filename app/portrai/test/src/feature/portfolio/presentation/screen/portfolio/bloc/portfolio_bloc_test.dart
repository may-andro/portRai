import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_supported_use_case.dart';
import '../../../../../../../mock/feature/portfolio/domain/use_case/mock_get_portfolio_use_case.dart';
import '../../../../../../../mock/feature/portfolio/domain/use_case/mock_watch_refreshed_portfolio_sections_use_case.dart';
import '../../../../../../../mock/feature/portfolio/presentation/screen/portfolio/tracking/mock_portfolio_tracking_delegate.dart';
import '../../../../../../../mock/feature/portfolio/test_data/portfolio_test_data.dart';
import '../../../../../../../mock/feature/user/domain/use_case/mock_get_guest_user_use_case.dart';

void main() {
  final portfolio = createPortfolioEntity();

  group('PortfolioBloc', () {
    late MockGetPortfolioUseCase getPortfolioUseCase;
    late MockPortfolioTrackingDelegate trackingDelegate;
    late MockIsFeatureEnabledUseCase isFeatureEnabledUseCase;
    late MockIsLocalAssistantSupportedUseCase local;
    late MockGetGuestUserUseCase getGuestUserUseCase;
    late MockWatchRefreshedPortfolioSectionsUseCase
    watchRefreshedPortfolioSectionsUseCase;

    PortfolioBloc buildBloc() => PortfolioBloc(
      getPortfolioUseCase,
      trackingDelegate,
      isFeatureEnabledUseCase,
      local,
      getGuestUserUseCase,
      watchRefreshedPortfolioSectionsUseCase,
    );

    setUp(() {
      getGuestUserUseCase = MockGetGuestUserUseCase()..stubCall(null);
      watchRefreshedPortfolioSectionsUseCase =
          MockWatchRefreshedPortfolioSectionsUseCase()
            ..stubCall(const Stream.empty());
      getPortfolioUseCase = MockGetPortfolioUseCase();
      trackingDelegate = MockPortfolioTrackingDelegate();
      isFeatureEnabledUseCase = MockIsFeatureEnabledUseCase()
        ..stubCall(
          definition: LocalAssistantFeatureFlags.aiAssistant,
          result: const Right(false),
        )
        ..stubCall(
          definition: RemoteAssistantFeatureFlags.remoteAssistant,
          result: const Right(false),
        );
      local = MockIsLocalAssistantSupportedUseCase()..stubCall(true);
    });

    for (final localEnabled in [false, true]) {
      for (final remoteEnabled in [false, true]) {
        for (final localSupported in [false, true]) {
          blocTest<PortfolioBloc, PortfolioState>(
            'should offer remote by flag and local by support when local=$localEnabled remote=$remoteEnabled localSupported=$localSupported',
            setUp: () {
              isFeatureEnabledUseCase
                ..stubCall(
                  definition: LocalAssistantFeatureFlags.aiAssistant,
                  result: Right(localEnabled),
                )
                ..stubCall(
                  definition: RemoteAssistantFeatureFlags.remoteAssistant,
                  result: Right(remoteEnabled),
                );
              local.stubCall(localSupported);
            },
            build: buildBloc,
            seed: () => LoadedState(portfolio: portfolio),
            act: (bloc) => bloc.add(const ScreenVisibleEvent()),
            expect: () {
              final expected = LoadedState(
                portfolio: portfolio,
                isLocalAssistantAvailable:
                    !remoteEnabled && localEnabled && localSupported,
                isRemoteAssistantAvailable: remoteEnabled,
              );
              return expected == LoadedState(portfolio: portfolio)
                  ? <PortfolioState>[]
                  : [expected];
            },
            verify: (_) {
              if (remoteEnabled) {
                verifyNever(
                  () => isFeatureEnabledUseCase(
                    LocalAssistantFeatureFlags.aiAssistant,
                  ),
                );
                verifyNever(() => local());
              } else if (!localEnabled) {
                verify(
                  () => isFeatureEnabledUseCase(
                    LocalAssistantFeatureFlags.aiAssistant,
                  ),
                ).called(1);
                verifyNever(() => local());
              } else {
                verify(() => local()).called(1);
              }
            },
          );
        }
      }
    }

    blocTest<PortfolioBloc, PortfolioState>(
      'should hide both assistants when the remote rollout check fails',
      setUp: () {
        isFeatureEnabledUseCase
          ..stubCall(
            definition: LocalAssistantFeatureFlags.aiAssistant,
            result: const Right(true),
          )
          ..stubCall(
            definition: RemoteAssistantFeatureFlags.remoteAssistant,
            result: const Left(FeatureFlagUnknownFailure()),
          );
      },
      build: buildBloc,
      seed: () =>
          LoadedState(portfolio: portfolio, isLocalAssistantAvailable: true),
      act: (bloc) => bloc.add(const ScreenVisibleEvent()),
      expect: () => [LoadedState(portfolio: portfolio)],
      verify: (_) {
        verifyNever(
          () => isFeatureEnabledUseCase(LocalAssistantFeatureFlags.aiAssistant),
        );
        verifyNever(() => local());
      },
    );

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
      'should load the saved role when loading the portfolio succeeds',
      setUp: () {
        getPortfolioUseCase.stubCall(
          Right<GetPortfolioFailure, PortfolioEntity>(portfolio),
        );
        getGuestUserUseCase.stubCall(
          const GuestUserEntity(role: UserRole.developer),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadPortfolioEvent()),
      expect: () => [
        const LoadingState(),
        LoadedState(portfolio: portfolio, userRole: UserRole.developer),
      ],
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
        bloc.add(const ViewStateVisibleEvent('loading_content_view'));
        bloc.add(const ViewStateVisibleEvent('loaded_content_view'));
        bloc.add(const ViewStateVisibleEvent('error_content_view'));
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

    test(
      'should reload the shown portfolio in place when a sync refreshes sections',
      () async {
        final refreshedSections =
            StreamController<Set<PortfolioSection>>.broadcast();
        addTearDown(refreshedSections.close);
        watchRefreshedPortfolioSectionsUseCase.stubCall(
          refreshedSections.stream.map(Right.new),
        );
        getPortfolioUseCase.stubCall(Right(portfolio));
        final bloc = buildBloc()..add(const LoadPortfolioEvent());
        addTearDown(bloc.close);
        await pumpEventQueue();
        final refreshedPortfolio = createPortfolioEntity(projects: const []);
        getPortfolioUseCase.stubCall(Right(refreshedPortfolio));

        refreshedSections.add({PortfolioSection.projects});
        await pumpEventQueue();

        final state = bloc.state as LoadedState;
        expect(state.portfolio, refreshedPortfolio);
      },
    );

    test(
      'should keep the shown portfolio when reloading after a sync fails',
      () async {
        final refreshedSections =
            StreamController<Set<PortfolioSection>>.broadcast();
        addTearDown(refreshedSections.close);
        watchRefreshedPortfolioSectionsUseCase.stubCall(
          refreshedSections.stream.map(Right.new),
        );
        getPortfolioUseCase.stubCall(Right(portfolio));
        final bloc = buildBloc()..add(const LoadPortfolioEvent());
        addTearDown(bloc.close);
        await pumpEventQueue();
        getPortfolioUseCase.stubCall(const Left(GetPortfolioUnknownFailure()));

        refreshedSections.add({PortfolioSection.profile});
        await pumpEventQueue();

        expect(bloc.state, isA<LoadedState>());
        expect((bloc.state as LoadedState).portfolio, portfolio);
      },
    );
  });
}
