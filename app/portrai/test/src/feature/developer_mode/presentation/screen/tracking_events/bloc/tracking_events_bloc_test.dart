import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/developer_mode/domain/entity/tracking_event_entity_fixture.dart';
import '../../../../../../../mock/feature/developer_mode/domain/use_case/mock_get_tracking_events_use_case.dart';
import '../../../../../../../mock/feature/developer_mode/presentation/screen/tracking_events/tracking/mock_tracking_events_tracking_delegate.dart';

void main() {
  final clickEvent = trackingEventEntityFixture(
    id: '3',
    parameters: {'event': 'click', 'area': 'experience', 'label': 'header_tab'},
  );
  final viewEvent = trackingEventEntityFixture(
    id: '2',
    name: 'view_impression',
    actionType: 'view',
    parameters: {'event': 'view_impression', 'label': 'skills_section'},
  );
  final screenViewEvent = trackingEventEntityFixture(
    name: 'screen_view',
    area: 'portfolio',
    actionType: null,
    parameters: {'event': 'screen_view', 'area': 'portfolio'},
  );
  final trackingEvents = [clickEvent, viewEvent, screenViewEvent];

  group('TrackingEventsBloc', () {
    late MockGetTrackingEventsUseCase getTrackingEventsUseCase;
    late MockTrackingEventsTrackingDelegate trackingDelegate;

    setUp(() {
      getTrackingEventsUseCase = MockGetTrackingEventsUseCase()
        ..stubCall(Right(trackingEvents));
      trackingDelegate = MockTrackingEventsTrackingDelegate();
    });

    TrackingEventsBloc buildBloc() =>
        TrackingEventsBloc(trackingDelegate, getTrackingEventsUseCase);

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should load the events when started',
      build: buildBloc,
      act: (bloc) => bloc.add(const TrackingEventsStartedEvent()),
      expect: () => [TrackingEventsLoadedState(trackingEvents)],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should show the error when the events are not kept',
      setUp: () => getTrackingEventsUseCase.stubCall(
        const Left(TrackingEventsNotKeptFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const TrackingEventsStartedEvent()),
      expect: () => const [
        TrackingEventsErrorState(TrackingEventsNotKeptFailure()),
      ],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should reload the events in place and keep the filters when refresh '
      'is clicked',
      seed: () => const TrackingEventsLoadedState(
        [],
        searchQuery: 'header',
        nameFilters: {'click'},
        areaFilter: 'experience',
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const TrackingEventsRefreshClickEvent()),
      expect: () => [
        TrackingEventsLoadedState(
          trackingEvents,
          searchQuery: 'header',
          nameFilters: const {'click'},
          areaFilter: 'experience',
        ),
      ],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should show the loader and then the events when retry is clicked '
      'after an error',
      seed: () =>
          const TrackingEventsErrorState(TrackingEventsNotKeptFailure()),
      build: buildBloc,
      act: (bloc) => bloc.add(const TrackingEventsRefreshClickEvent()),
      expect: () => [
        const TrackingEventsLoadingState(),
        TrackingEventsLoadedState(trackingEvents),
      ],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should toggle the name filter when a name chip is clicked twice',
      seed: () => TrackingEventsLoadedState(trackingEvents),
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const TrackingEventsNameFilterClickEvent('click'))
        ..add(const TrackingEventsNameFilterClickEvent('click')),
      expect: () => [
        TrackingEventsLoadedState(trackingEvents, nameFilters: const {'click'}),
        TrackingEventsLoadedState(trackingEvents),
      ],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should select and then clear the area when an area is picked',
      seed: () => TrackingEventsLoadedState(trackingEvents),
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const TrackingEventsAreaFilterClickEvent('portfolio'))
        ..add(const TrackingEventsAreaFilterClickEvent(null)),
      expect: () => [
        TrackingEventsLoadedState(trackingEvents, areaFilter: 'portfolio'),
        TrackingEventsLoadedState(trackingEvents),
      ],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should open and then close the details when an event is tapped twice',
      seed: () => TrackingEventsLoadedState(trackingEvents),
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const TrackingEventClickEvent('3'))
        ..add(const TrackingEventClickEvent('3')),
      expect: () => [
        TrackingEventsLoadedState(trackingEvents, selectedTrackingEventId: '3'),
        TrackingEventsLoadedState(trackingEvents),
      ],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should open the tapped event instead when another one is open',
      seed: () => TrackingEventsLoadedState(
        trackingEvents,
        selectedTrackingEventId: '3',
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const TrackingEventClickEvent('2')),
      expect: () => [
        TrackingEventsLoadedState(trackingEvents, selectedTrackingEventId: '2'),
      ],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should keep the open event when the filters are cleared',
      seed: () => TrackingEventsLoadedState(
        trackingEvents,
        nameFilters: const {'click'},
        selectedTrackingEventId: '3',
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const TrackingEventsClearFiltersClickEvent()),
      expect: () => [
        TrackingEventsLoadedState(trackingEvents, selectedTrackingEventId: '3'),
      ],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should clear the search and every filter when clear is clicked',
      seed: () => TrackingEventsLoadedState(
        trackingEvents,
        searchQuery: 'header',
        nameFilters: const {'click'},
        areaFilter: 'experience',
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const TrackingEventsClearFiltersClickEvent()),
      expect: () => [TrackingEventsLoadedState(trackingEvents)],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should ignore the search when the events are not shown',
      build: buildBloc,
      act: (bloc) => bloc.add(const TrackingEventsSearchChangedEvent('x')),
      expect: () => const <TrackingEventsState>[],
    );

    blocTest<TrackingEventsBloc, TrackingEventsState>(
      'should track the screen view when the screen becomes visible',
      build: buildBloc,
      act: (bloc) => bloc.add(const ScreenVisibleEvent()),
      verify: (_) => verify(() => trackingDelegate.trackScreenView()).called(1),
    );
  });

  group('TrackingEventsLoadedState', () {
    TrackingEventsLoadedState loadedState({
      String searchQuery = '',
      Set<String> nameFilters = const {},
      String? areaFilter,
    }) => TrackingEventsLoadedState(
      trackingEvents,
      searchQuery: searchQuery,
      nameFilters: nameFilters,
      areaFilter: areaFilter,
    );

    test('should show every event when nothing narrows the list', () {
      expect(loadedState().visibleTrackingEvents, trackingEvents);
    });

    test('should match every search word against the parameters when '
        'searching', () {
      expect(loadedState(searchQuery: 'HEADER click').visibleTrackingEvents, [
        clickEvent,
      ]);
      expect(loadedState(searchQuery: 'label').visibleTrackingEvents, [
        clickEvent,
        viewEvent,
      ]);
    });

    test('should show events with any of the names when names are '
        'selected', () {
      expect(
        loadedState(
          nameFilters: {'click', 'screen_view'},
        ).visibleTrackingEvents,
        [clickEvent, screenViewEvent],
      );
    });

    test('should show only the events of the area when an area is '
        'selected', () {
      expect(loadedState(areaFilter: 'portfolio').visibleTrackingEvents, [
        screenViewEvent,
      ]);
    });

    test('should hide the open event when the filters leave it out', () {
      final state = TrackingEventsLoadedState(
        trackingEvents,
        selectedTrackingEventId: '3',
      );

      expect(state.selectedTrackingEvent, clickEvent);
      expect(
        state.copyWith(nameFilters: {'screen_view'}).selectedTrackingEvent,
        isNull,
      );
    });

    test('should count the events per name and area by most frequent first '
        'when counted', () {
      final state = loadedState();

      expect(state.nameCounts, {
        'click': 1,
        'view_impression': 1,
        'screen_view': 1,
      });
      expect(state.areaCounts, {'experience': 2, 'portfolio': 1});
      expect(state.areaCounts.keys.first, 'experience');
    });
  });
}
