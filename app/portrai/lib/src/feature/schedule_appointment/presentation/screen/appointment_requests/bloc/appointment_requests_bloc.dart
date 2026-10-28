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
      LoadedState(
        requests: loadedState.requests,
        decidingRequestId: event.requestId,
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
      emit(LoadedState(requests: loadedState.requests, actionFailure: failure));
      // The request changed or is gone, so show it as it is now.
      if (failure is DecideAppointmentRequestNotFoundFailure ||
          failure is DecideAppointmentRequestPermissionDeniedFailure) {
        await _loadRequests(emit);
      }
      return;
    }

    emit(
      LoadedState(
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

  Future<void> _loadRequests(Emitter<AppointmentRequestsState> emit) async {
    emit(const LoadingState());
    final requestsEither = await _getAppointmentRequestsUseCase();
    if (requestsEither.isLeft) {
      emit(ErrorState(requestsEither.left));
      return;
    }
    emit(LoadedState(requests: requestsEither.right));
  }
}
