import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/appointment_requests_event.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/appointment_requests_state.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/tracking/_tracking.dart';

@register
class AppointmentRequestsBloc
    extends Bloc<AppointmentRequestsEvent, AppointmentRequestsState> {
  AppointmentRequestsBloc(
    this._getAppointmentRequestsUseCase,
    this._decideAppointmentRequestUseCase,
    this._trackingDelegate,
  ) : super(const LoadingState()) {
    on<AppointmentRequestsStartedEvent>(
      _mapAppointmentRequestsStartedEventToState,
    );
    on<AppointmentRequestsRetryClickEvent>(
      _mapAppointmentRequestsRetryClickEventToState,
    );
    on<AppointmentRequestDecisionClickEvent>(
      _mapAppointmentRequestDecisionClickEventToState,
    );
    on<AppointmentRequestsSearchChangedEvent>(
      _mapAppointmentRequestsSearchChangedEventToState,
    );
    on<AppointmentRequestsFilterClickEvent>(
      _mapAppointmentRequestsFilterClickEventToState,
    );
    on<AppointmentRequestsWeekClickEvent>(
      _mapAppointmentRequestsWeekClickEventToState,
    );
    on<AppointmentRequestsDayClickEvent>(
      _mapAppointmentRequestsDayClickEventToState,
    );
    on<AppointmentRequestsClearFiltersClickEvent>(
      _mapAppointmentRequestsClearFiltersClickEventToState,
    );
  }

  final GetAppointmentRequestsUseCase _getAppointmentRequestsUseCase;
  final DecideAppointmentRequestUseCase _decideAppointmentRequestUseCase;
  final AppointmentRequestsTrackingDelegate _trackingDelegate;

  Future<void> _mapAppointmentRequestsStartedEventToState(
    AppointmentRequestsStartedEvent event,
    Emitter<AppointmentRequestsState> emit,
  ) async {
    _trackingDelegate.trackScreenView();
    await _loadRequests(emit);
  }

  Future<void> _mapAppointmentRequestsRetryClickEventToState(
    AppointmentRequestsRetryClickEvent event,
    Emitter<AppointmentRequestsState> emit,
  ) async {
    await _loadRequests(emit);
  }

  Future<void> _mapAppointmentRequestDecisionClickEventToState(
    AppointmentRequestDecisionClickEvent event,
    Emitter<AppointmentRequestsState> emit,
  ) async {
    final loadedState = state;
    if (loadedState is! LoadedState || loadedState.decidingRequestId != null) {
      return;
    }

    _trackingDelegate.trackDecisionClick(
      decision: event.decision.name,
      requestId: event.requestId,
    );
    emit(
      loadedState.copyWith(
        decidingRequestId: event.requestId,
        clearActionFailure: true,
      ),
    );

    final decideEither = await _decideAppointmentRequestUseCase(
      DecideAppointmentRequestParam(
        requestId: event.requestId,
        decision: event.decision,
      ),
    );
    if (decideEither.isLeft) {
      final failure = decideEither.left;
      emit(loadedState.copyWith(actionFailure: failure));
      // The request changed or is gone, so show it as it is now.
      if (failure is DecideAppointmentRequestNotFoundFailure ||
          failure is DecideAppointmentRequestPermissionDeniedFailure) {
        await _loadRequests(emit);
      }
      return;
    }

    emit(
      loadedState.copyWith(
        clearActionFailure: true,
        requests: [
          for (final request in loadedState.requests)
            if (request.id == event.requestId)
              request.copyWith(status: event.decision.status)
            else
              request,
        ],
      ),
    );
  }

  void _mapAppointmentRequestsSearchChangedEventToState(
    AppointmentRequestsSearchChangedEvent event,
    Emitter<AppointmentRequestsState> emit,
  ) {
    final loadedState = state;
    if (loadedState is! LoadedState) return;
    emit(
      loadedState.copyWith(
        searchQuery: event.searchQuery,
        clearActionFailure: true,
      ),
    );
  }

  void _mapAppointmentRequestsFilterClickEventToState(
    AppointmentRequestsFilterClickEvent event,
    Emitter<AppointmentRequestsState> emit,
  ) {
    final loadedState = state;
    if (loadedState is! LoadedState) return;
    final isSelected = loadedState.filter != event.filter;
    if (isSelected) _trackingDelegate.trackFilterSelection(event.filter.name);
    emit(
      loadedState.copyWith(
        filter: event.filter,
        clearFilter: !isSelected,
        clearActionFailure: true,
      ),
    );
  }

  void _mapAppointmentRequestsWeekClickEventToState(
    AppointmentRequestsWeekClickEvent event,
    Emitter<AppointmentRequestsState> emit,
  ) {
    final loadedState = state;
    if (loadedState is! LoadedState) return;
    _trackingDelegate.trackWeekClick(event.label);
    emit(
      loadedState.copyWith(
        weekStart: appointmentWeekStartOf(event.weekStart),
        clearSelectedDay: true,
        clearActionFailure: true,
      ),
    );
  }

  void _mapAppointmentRequestsDayClickEventToState(
    AppointmentRequestsDayClickEvent event,
    Emitter<AppointmentRequestsState> emit,
  ) {
    final loadedState = state;
    if (loadedState is! LoadedState) return;
    final day = appointmentDayOf(event.day);
    final isSelected = loadedState.selectedDay != day;
    if (isSelected) _trackingDelegate.trackDayClick(day);
    emit(
      loadedState.copyWith(
        selectedDay: day,
        clearSelectedDay: !isSelected,
        clearActionFailure: true,
      ),
    );
  }

  void _mapAppointmentRequestsClearFiltersClickEventToState(
    AppointmentRequestsClearFiltersClickEvent event,
    Emitter<AppointmentRequestsState> emit,
  ) {
    final loadedState = state;
    if (loadedState is! LoadedState) return;
    _trackingDelegate.trackClearFiltersClick();
    emit(
      loadedState.copyWith(
        searchQuery: '',
        clearFilter: true,
        clearSelectedDay: true,
        clearActionFailure: true,
      ),
    );
  }

  /// Keeps the search, the filter and the week of a list shown before.
  Future<void> _loadRequests(Emitter<AppointmentRequestsState> emit) async {
    final previousState = state;
    emit(const LoadingState());
    final requestsEither = await _getAppointmentRequestsUseCase();
    if (requestsEither.isLeft) {
      emit(ErrorState(requestsEither.left));
      return;
    }

    final requests = requestsEither.right;
    if (previousState is LoadedState) {
      emit(
        previousState.copyWith(
          requests: requests,
          clearDecidingRequestId: true,
          clearActionFailure: true,
        ),
      );
      return;
    }

    // Opens on the week of the next request to answer, or else this week.
    final now = DateTime.now();
    final nextOpenRequest = requests
        .where((request) => request.isAnswerableAt(now))
        .firstOrNull;
    emit(
      LoadedState(
        requests: requests,
        weekStart: appointmentWeekStartOf(nextOpenRequest?.slotStart ?? now),
      ),
    );
  }
}
