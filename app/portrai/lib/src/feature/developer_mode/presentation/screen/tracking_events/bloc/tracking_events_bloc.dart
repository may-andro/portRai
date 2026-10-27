import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/bloc/tracking_events_event.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/bloc/tracking_events_state.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/tracking_events/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class TrackingEventsBloc extends Bloc<TrackingEventsEvent, TrackingEventsState>
    with ScreenTrackingBlocMixin<TrackingEventsEvent, TrackingEventsState> {
  TrackingEventsBloc(this._trackingDelegate, this._getTrackingEventsUseCase)
    : super(const TrackingEventsLoadingState()) {
    on<TrackingEventsStartedEvent>(_mapTrackingEventsStartedEventToState);
    on<TrackingEventsRefreshClickEvent>(
      _mapTrackingEventsRefreshClickEventToState,
    );
    on<TrackingEventsSearchChangedEvent>(
      _mapTrackingEventsSearchChangedEventToState,
    );
    on<TrackingEventsNameFilterClickEvent>(
      _mapTrackingEventsNameFilterClickEventToState,
    );
    on<TrackingEventsAreaFilterClickEvent>(
      _mapTrackingEventsAreaFilterClickEventToState,
    );
    on<TrackingEventClickEvent>(_mapTrackingEventClickEventToState);
    on<TrackingEventsClearFiltersClickEvent>(
      _mapTrackingEventsClearFiltersClickEventToState,
    );
    trackScreenViewOn<ScreenVisibleEvent>();
    trackViewEventOn<ViewStateVisibleEvent>((event) => event.trackingId);
  }

  final TrackingEventsTrackingDelegate _trackingDelegate;
  final GetTrackingEventsUseCase _getTrackingEventsUseCase;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  Future<void> _mapTrackingEventsStartedEventToState(
    TrackingEventsStartedEvent event,
    Emitter<TrackingEventsState> emit,
  ) => _loadTrackingEvents(emit);

  /// Reloads in place when the events are shown, keeping the search and the
  /// filters; shows the loader again after an error.
  Future<void> _mapTrackingEventsRefreshClickEventToState(
    TrackingEventsRefreshClickEvent event,
    Emitter<TrackingEventsState> emit,
  ) async {
    if (state is TrackingEventsErrorState) {
      emit(const TrackingEventsLoadingState());
    }
    await _loadTrackingEvents(emit);
  }

  Future<void> _loadTrackingEvents(Emitter<TrackingEventsState> emit) async {
    final trackingEventsEither = await _getTrackingEventsUseCase();
    trackingEventsEither.fold(
      (failure) => emit(TrackingEventsErrorState(failure)),
      (trackingEvents) => emit(switch (state) {
        final TrackingEventsLoadedState loadedState => loadedState.copyWith(
          trackingEvents: trackingEvents,
        ),
        _ => TrackingEventsLoadedState(trackingEvents),
      }),
    );
  }

  void _mapTrackingEventsSearchChangedEventToState(
    TrackingEventsSearchChangedEvent event,
    Emitter<TrackingEventsState> emit,
  ) {
    if (state case final TrackingEventsLoadedState loadedState) {
      emit(loadedState.copyWith(searchQuery: event.searchQuery));
    }
  }

  void _mapTrackingEventsNameFilterClickEventToState(
    TrackingEventsNameFilterClickEvent event,
    Emitter<TrackingEventsState> emit,
  ) {
    if (state case final TrackingEventsLoadedState loadedState) {
      final nameFilters = {...loadedState.nameFilters};
      if (!nameFilters.remove(event.name)) nameFilters.add(event.name);
      emit(loadedState.copyWith(nameFilters: nameFilters));
    }
  }

  void _mapTrackingEventsAreaFilterClickEventToState(
    TrackingEventsAreaFilterClickEvent event,
    Emitter<TrackingEventsState> emit,
  ) {
    if (state case final TrackingEventsLoadedState loadedState) {
      emit(
        loadedState.copyWith(
          areaFilter: event.area,
          clearAreaFilter: event.area == null,
        ),
      );
    }
  }

  void _mapTrackingEventClickEventToState(
    TrackingEventClickEvent event,
    Emitter<TrackingEventsState> emit,
  ) {
    if (state case final TrackingEventsLoadedState loadedState) {
      final isOpen = loadedState.selectedTrackingEventId == event.id;
      emit(
        loadedState.copyWith(
          selectedTrackingEventId: event.id,
          clearSelectedTrackingEvent: isOpen,
        ),
      );
    }
  }

  void _mapTrackingEventsClearFiltersClickEventToState(
    TrackingEventsClearFiltersClickEvent event,
    Emitter<TrackingEventsState> emit,
  ) {
    if (state case final TrackingEventsLoadedState loadedState) {
      emit(
        TrackingEventsLoadedState(
          loadedState.trackingEvents,
          selectedTrackingEventId: loadedState.selectedTrackingEventId,
        ),
      );
    }
  }
}
