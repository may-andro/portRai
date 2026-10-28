import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/bloc/schedule_appointment_event.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/bloc/schedule_appointment_state.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class ScheduleAppointmentBloc
    extends Bloc<ScheduleAppointmentEvent, ScheduleAppointmentState>
    with
        ScreenTrackingBlocMixin<
          ScheduleAppointmentEvent,
          ScheduleAppointmentState
        > {
  ScheduleAppointmentBloc(
    this._getAppointmentSlotsUseCase,
    this._requestAppointmentUseCase,
    this._openExternalUrlUseCase,
    this._getPrivacyPolicyUrlUseCase,
    this._trackingDelegate,
  ) : super(const ScheduleAppointmentState()) {
    trackScreenViewOn<ScreenVisibleEvent>();
    on<LoadAppointmentSlotsEvent>(_mapLoadAppointmentSlotsEventToState);
    on<AppointmentSlotsRetryClickEvent>(
      _mapAppointmentSlotsRetryClickEventToState,
    );
    on<AppointmentDayClickEvent>(_mapAppointmentDayClickEventToState);
    on<AppointmentSlotClickEvent>(_mapAppointmentSlotClickEventToState);
    on<PrivacyPolicyClickEvent>(_mapPrivacyPolicyClickEventToState);
    on<SendAppointmentRequestClickEvent>(
      _mapSendAppointmentRequestClickEventToState,
    );
  }

  final GetAppointmentSlotsUseCase _getAppointmentSlotsUseCase;
  final RequestAppointmentUseCase _requestAppointmentUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final GetPrivacyPolicyUrlUseCase _getPrivacyPolicyUrlUseCase;
  final ScheduleAppointmentTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  Future<void> _mapLoadAppointmentSlotsEventToState(
    LoadAppointmentSlotsEvent event,
    Emitter<ScheduleAppointmentState> emit,
  ) => _loadAppointmentSlots(emit);

  Future<void> _mapAppointmentSlotsRetryClickEventToState(
    AppointmentSlotsRetryClickEvent event,
    Emitter<ScheduleAppointmentState> emit,
  ) => _loadAppointmentSlots(emit);

  Future<void> _loadAppointmentSlots(
    Emitter<ScheduleAppointmentState> emit,
  ) async {
    emit(const ScheduleAppointmentState());
    final appointmentSlotsEither = await _getAppointmentSlotsUseCase();
    if (appointmentSlotsEither.isLeft) {
      emit(
        ScheduleAppointmentState(
          status: ScheduleAppointmentStatus.loadFailed,
          loadFailure: appointmentSlotsEither.left,
        ),
      );
      return;
    }
    final appointmentSlots = appointmentSlotsEither.right;
    emit(
      ScheduleAppointmentState(
        status: ScheduleAppointmentStatus.choosing,
        appointmentSlots: appointmentSlots,
        selectedDay: appointmentSlots.slotsByLocalDay.keys.firstOrNull,
      ),
    );
  }

  void _mapAppointmentDayClickEventToState(
    AppointmentDayClickEvent event,
    Emitter<ScheduleAppointmentState> emit,
  ) {
    if (state.status != ScheduleAppointmentStatus.choosing) return;
    _trackingDelegate.trackDayClick(
      label: event.label,
      day: event.day.toIso8601String().substring(0, 10),
    );
    emit(state.copyWith(selectedDay: event.day, clearSelectedSlot: true));
  }

  void _mapAppointmentSlotClickEventToState(
    AppointmentSlotClickEvent event,
    Emitter<ScheduleAppointmentState> emit,
  ) {
    if (state.status != ScheduleAppointmentStatus.choosing) return;
    _trackingDelegate.trackSlotClick(
      label: event.label,
      slotStart: event.slot.toUtc().toIso8601String(),
    );
    emit(state.copyWith(selectedSlot: event.slot));
  }

  Future<void> _mapPrivacyPolicyClickEventToState(
    PrivacyPolicyClickEvent event,
    Emitter<ScheduleAppointmentState> emit,
  ) async {
    _trackingDelegate.trackPrivacyPolicyClick(event.label);
    final urlEither = await _getPrivacyPolicyUrlUseCase();
    if (urlEither.isLeft) return;
    await _openExternalUrlUseCase(OpenExternalUrlParam(urlEither.right));
  }

  Future<void> _mapSendAppointmentRequestClickEventToState(
    SendAppointmentRequestClickEvent event,
    Emitter<ScheduleAppointmentState> emit,
  ) async {
    final selectedSlot = state.selectedSlot;
    if (state.status != ScheduleAppointmentStatus.choosing ||
        selectedSlot == null) {
      return;
    }

    _trackingDelegate.trackSendClick(event.label);
    emit(
      state.copyWith(
        status: ScheduleAppointmentStatus.sending,
        clearSendFailure: true,
      ),
    );

    final requestAppointmentEither = await _requestAppointmentUseCase(
      RequestAppointmentParam(
        slotStart: selectedSlot,
        name: event.name,
        email: event.email,
        topic: event.topic,
        message: event.message,
        hasAcceptedPrivacyPolicy: event.hasAcceptedPrivacyPolicy,
      ),
    );
    if (requestAppointmentEither.isRight) {
      _trackingDelegate.trackViewEvent('appointment_request_sent_view');
      emit(state.copyWith(status: ScheduleAppointmentStatus.sent));
      return;
    }

    final failure = requestAppointmentEither.left;
    if (failure is! RequestAppointmentSlotUnavailableFailure) {
      emit(
        state.copyWith(
          status: ScheduleAppointmentStatus.choosing,
          sendFailure: failure,
        ),
      );
      return;
    }
    // Someone else took the time, so offer the times that are still free.
    final appointmentSlotsEither = await _getAppointmentSlotsUseCase();
    final appointmentSlots = appointmentSlotsEither.isRight
        ? appointmentSlotsEither.right
        : state.appointmentSlots;
    final slotsByDay = appointmentSlots?.slotsByLocalDay ?? const {};
    final selectedDay = state.selectedDay;
    emit(
      ScheduleAppointmentState(
        status: ScheduleAppointmentStatus.choosing,
        appointmentSlots: appointmentSlots,
        selectedDay: slotsByDay.containsKey(selectedDay)
            ? selectedDay
            : slotsByDay.keys.firstOrNull,
        sendFailure: failure,
      ),
    );
  }
}
