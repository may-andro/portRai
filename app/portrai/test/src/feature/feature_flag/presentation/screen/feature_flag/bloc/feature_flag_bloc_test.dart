import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_get_all_feature_flags_use_case.dart';
import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_reset_feature_flags_use_case.dart';
import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_update_feature_flag_use_case.dart';
import '../../../../../../../mock/feature/feature_flag/presentation/screen/feature_flag/tracking/mock_feature_flag_tracking_delegate.dart';

void main() {
  const testimonialsDefinition = AppFeatureFlagDefinition(
    key: 'feature_testimonials_section',
    defaultValue: false,
    displayName: 'Testimonials Section',
    description: 'Enables the testimonials section on portfolio page',
  );
  const servicesDefinition = AppFeatureFlagDefinition(
    key: 'feature_services_section',
    defaultValue: false,
    displayName: 'Services Section',
    description: 'Enables the services section on portfolio page',
  );
  const testimonialsFlag = AppFeatureFlagEntity(
    flag: testimonialsDefinition,
    isEnabled: false,
    isOverridden: false,
  );
  const servicesFlag = AppFeatureFlagEntity(
    flag: servicesDefinition,
    isEnabled: true,
    isOverridden: false,
    hasRemoteSource: true,
    remoteValue: true,
  );
  const allFlags = [testimonialsFlag, servicesFlag];

  setUpAll(() {
    registerFallbackValue(testimonialsFlag);
  });

  group('FeatureFlagBloc', () {
    late MockGetAllFeatureFlagsUseCase getAllFeatureFlagsUseCase;
    late MockUpdateFeatureFlagUseCase updateFeatureFlagUseCase;
    late MockResetFeatureFlagsUseCase resetFeatureFlagsUseCase;
    late MockFeatureFlagTrackingDelegate trackingDelegate;

    FeatureFlagBloc buildBloc() {
      return FeatureFlagBloc(
        getAllFeatureFlagsUseCase,
        updateFeatureFlagUseCase,
        resetFeatureFlagsUseCase,
        trackingDelegate,
      );
    }

    setUp(() {
      getAllFeatureFlagsUseCase = MockGetAllFeatureFlagsUseCase();
      updateFeatureFlagUseCase = MockUpdateFeatureFlagUseCase();
      resetFeatureFlagsUseCase = MockResetFeatureFlagsUseCase();
      trackingDelegate = MockFeatureFlagTrackingDelegate();
    });

    test('should start with the initial state when bloc is created', () {
      expect(buildBloc().state, const FeatureFlagInitialState());
    });

    group('LoadFeatureFlagEvent', () {
      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should emit loading then loaded when fetching flags succeeds',
        setUp: () => getAllFeatureFlagsUseCase.stubCall(
          const Right<GetAllFeatureFlagsFailure, List<AppFeatureFlagEntity>>(
            allFlags,
          ),
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadFeatureFlagEvent()),
        expect: () => const [
          FeatureFlagLoadingState(),
          FeatureFlagLoadedState(allFlags),
        ],
      );

      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should emit loading then error when fetching flags fails',
        setUp: () => getAllFeatureFlagsUseCase.stubCall(
          const Left<GetAllFeatureFlagsFailure, List<AppFeatureFlagEntity>>(
            FeatureFlagsNotFoundFailure(),
          ),
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadFeatureFlagEvent()),
        expect: () => [
          const FeatureFlagLoadingState(),
          const FeatureFlagErrorState('FeatureFlagsNotFoundFailure'),
        ],
      );

      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should preserve loaded state properties when reloading succeeds',
        setUp: () => getAllFeatureFlagsUseCase.stubCall(
          const Right<GetAllFeatureFlagsFailure, List<AppFeatureFlagEntity>>(
            allFlags,
          ),
        ),
        seed: () => const FeatureFlagLoadedState(
          [testimonialsFlag],
          searchQuery: 'testimonials',
          hasManipulatedFlags: true,
          viewMode: FeatureFlagViewMode.grid,
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadFeatureFlagEvent()),
        expect: () => [
          const FeatureFlagLoadingState(),
          const FeatureFlagLoadedState(
            allFlags,
            searchQuery: 'testimonials',
            hasManipulatedFlags: true,
            viewMode: FeatureFlagViewMode.grid,
          ),
        ],
      );
    });

    group('ToggleFeatureFlagEvent', () {
      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should emit an updated loaded state when a flag is toggled from loaded state',
        setUp: () => updateFeatureFlagUseCase.stubCall(
          const Right<UpdateFeatureFlagFailure, void>(null),
        ),
        seed: () => const FeatureFlagLoadedState(
          allFlags,
          searchQuery: 'services',
          viewMode: FeatureFlagViewMode.grid,
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(const ToggleFeatureFlagEvent(testimonialsFlag)),
        expect: () => [
          const FeatureFlagLoadedState(
            [
              AppFeatureFlagEntity(
                flag: testimonialsDefinition,
                isEnabled: true,
                isOverridden: true,
              ),
              servicesFlag,
            ],
            searchQuery: 'services',
            hasManipulatedFlags: true,
            viewMode: FeatureFlagViewMode.grid,
          ),
        ],
        verify: (_) {
          verify(
            () => updateFeatureFlagUseCase(
              const AppFeatureFlagEntity(
                flag: testimonialsDefinition,
                isEnabled: true,
                isOverridden: true,
              ),
            ),
          ).called(1);
        },
      );

      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should emit nothing when a flag is toggled outside loaded state',
        build: buildBloc,
        act: (bloc) => bloc.add(const ToggleFeatureFlagEvent(testimonialsFlag)),
        expect: () => const <FeatureFlagState>[],
        verify: (_) {
          verifyNever(() => updateFeatureFlagUseCase(any()));
        },
      );
    });

    group('ResetAllFeatureFlagsEvent', () {
      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should reload flags and preserve search query and view mode when reset succeeds',
        setUp: () {
          resetFeatureFlagsUseCase.stubCall(
            const Right<ResetFeatureFlagsFailure, void>(null),
          );
          getAllFeatureFlagsUseCase.stubCall(
            const Right<GetAllFeatureFlagsFailure, List<AppFeatureFlagEntity>>(
              allFlags,
            ),
          );
        },
        seed: () => const FeatureFlagLoadedState(
          [testimonialsFlag],
          searchQuery: 'testimonials',
          hasManipulatedFlags: true,
          viewMode: FeatureFlagViewMode.grid,
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(const ResetAllFeatureFlagsEvent()),
        expect: () => [
          const FeatureFlagLoadingState(),
          const FeatureFlagLoadedState(
            allFlags,
            searchQuery: 'testimonials',
            viewMode: FeatureFlagViewMode.grid,
          ),
        ],
        verify: (_) {
          verify(() => resetFeatureFlagsUseCase()).called(1);
        },
      );

      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should emit error when reloading flags fails after reset',
        setUp: () {
          resetFeatureFlagsUseCase.stubCall(
            const Right<ResetFeatureFlagsFailure, void>(null),
          );
          getAllFeatureFlagsUseCase.stubCall(
            const Left<GetAllFeatureFlagsFailure, List<AppFeatureFlagEntity>>(
              FeatureFlagsNotFoundFailure(),
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ResetAllFeatureFlagsEvent()),
        expect: () => [
          const FeatureFlagLoadingState(),
          const FeatureFlagErrorState('FeatureFlagsNotFoundFailure'),
        ],
      );
    });

    group('SearchFeatureFlagsEvent', () {
      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should update the search query when search is requested from loaded state',
        seed: () => const FeatureFlagLoadedState(allFlags),
        build: buildBloc,
        act: (bloc) => bloc.add(const SearchFeatureFlagsEvent('services')),
        expect: () => const [
          FeatureFlagLoadedState(allFlags, searchQuery: 'services'),
        ],
      );

      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should emit nothing when search is requested outside loaded state',
        build: buildBloc,
        act: (bloc) => bloc.add(const SearchFeatureFlagsEvent('services')),
        expect: () => const <FeatureFlagState>[],
      );
    });

    group('ToggleViewModeEvent', () {
      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should switch to grid mode when toggled from list mode',
        seed: () => const FeatureFlagLoadedState(allFlags),
        build: buildBloc,
        act: (bloc) => bloc.add(const ToggleViewModeEvent()),
        expect: () => const [
          FeatureFlagLoadedState(allFlags, viewMode: FeatureFlagViewMode.grid),
        ],
      );

      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should switch to list mode when toggled from grid mode',
        seed: () => const FeatureFlagLoadedState(
          allFlags,
          viewMode: FeatureFlagViewMode.grid,
        ),
        build: buildBloc,
        act: (bloc) => bloc.add(const ToggleViewModeEvent()),
        expect: () => const [FeatureFlagLoadedState(allFlags)],
      );

      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should emit nothing when view mode is toggled outside loaded state',
        build: buildBloc,
        act: (bloc) => bloc.add(const ToggleViewModeEvent()),
        expect: () => const <FeatureFlagState>[],
      );
    });

    group('tracking events', () {
      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should track the screen when screen becomes visible',
        build: buildBloc,
        act: (bloc) => bloc.add(const ScreenVisibleEvent()),
        expect: () => const <FeatureFlagState>[],
        verify: (_) {
          verify(() => trackingDelegate.trackScreenView()).called(1);
        },
      );

      blocTest<FeatureFlagBloc, FeatureFlagState>(
        'should track the visible view state when view content becomes visible',
        build: buildBloc,
        act: (bloc) => bloc.add(ViewStateVisibleEvent.success()),
        expect: () => const <FeatureFlagState>[],
        verify: (_) {
          verify(
            () => trackingDelegate.trackViewEvent(
              'feature_flag_loaded_content_view',
            ),
          ).called(1);
        },
      );
    });
  });
}
