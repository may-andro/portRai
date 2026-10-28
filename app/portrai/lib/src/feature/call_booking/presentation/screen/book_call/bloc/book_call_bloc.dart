import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';
import 'package:portrai/src/feature/call_booking/presentation/extension/_extension.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/bloc/book_call_event.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/bloc/book_call_state.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/tracking/_tracking.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/utility/legal_urls.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class BookCallBloc extends Bloc<BookCallEvent, BookCallState>
    with ScreenTrackingBlocMixin<BookCallEvent, BookCallState> {
  BookCallBloc(
    this._getCallSlotsUseCase,
    this._requestCallUseCase,
    this._openExternalUrlUseCase,
    this._trackingDelegate,
  ) : super(const BookCallState()) {
    trackScreenViewOn<ScreenVisibleEvent>();
    on<LoadCallSlotsEvent>(_mapLoadCallSlotsEventToState);
    on<CallSlotsRetryClickEvent>(_mapCallSlotsRetryClickEventToState);
    on<CallDayClickEvent>(_mapCallDayClickEventToState);
    on<CallSlotClickEvent>(_mapCallSlotClickEventToState);
    on<PrivacyPolicyClickEvent>(_mapPrivacyPolicyClickEventToState);
    on<SendCallRequestClickEvent>(_mapSendCallRequestClickEventToState);
  }

  final GetCallSlotsUseCase _getCallSlotsUseCase;
  final RequestCallUseCase _requestCallUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final BookCallTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;

  Future<void> _mapLoadCallSlotsEventToState(
    LoadCallSlotsEvent event,
    Emitter<BookCallState> emit,
  ) => _loadCallSlots(emit);

  Future<void> _mapCallSlotsRetryClickEventToState(
    CallSlotsRetryClickEvent event,
    Emitter<BookCallState> emit,
  ) => _loadCallSlots(emit);

  Future<void> _loadCallSlots(Emitter<BookCallState> emit) async {
    emit(const BookCallState());
    final callSlotsEither = await _getCallSlotsUseCase();
    if (callSlotsEither.isLeft) {
      emit(
        BookCallState(
          status: BookCallStatus.loadFailed,
          loadFailure: callSlotsEither.left,
        ),
      );
      return;
    }
    final callSlots = callSlotsEither.right;
    emit(
      BookCallState(
        status: BookCallStatus.choosing,
        callSlots: callSlots,
        selectedDay: callSlots.slotsByLocalDay.keys.firstOrNull,
      ),
    );
  }

  void _mapCallDayClickEventToState(
    CallDayClickEvent event,
    Emitter<BookCallState> emit,
  ) {
    if (state.status != BookCallStatus.choosing) return;
    _trackingDelegate.trackDayClick(
      label: event.label,
      day: event.day.toIso8601String().substring(0, 10),
    );
    emit(state.copyWith(selectedDay: event.day, clearSelectedSlot: true));
  }

  void _mapCallSlotClickEventToState(
    CallSlotClickEvent event,
    Emitter<BookCallState> emit,
  ) {
    if (state.status != BookCallStatus.choosing) return;
    _trackingDelegate.trackSlotClick(
      label: event.label,
      slotStart: event.slot.toUtc().toIso8601String(),
    );
    emit(state.copyWith(selectedSlot: event.slot));
  }

  Future<void> _mapPrivacyPolicyClickEventToState(
    PrivacyPolicyClickEvent event,
    Emitter<BookCallState> emit,
  ) async {
    _trackingDelegate.trackPrivacyPolicyClick(event.label);
    await _openExternalUrlUseCase(OpenExternalUrlParam(privacyPolicyUrl));
  }

  Future<void> _mapSendCallRequestClickEventToState(
    SendCallRequestClickEvent event,
    Emitter<BookCallState> emit,
  ) async {
    final selectedSlot = state.selectedSlot;
    if (state.status != BookCallStatus.choosing || selectedSlot == null) {
      return;
    }

    _trackingDelegate.trackSendClick(event.label);
    emit(
      state.copyWith(status: BookCallStatus.sending, clearSendFailure: true),
    );

    final requestCallEither = await _requestCallUseCase(
      RequestCallParam(
        slotStart: selectedSlot,
        name: event.name,
        email: event.email,
        topic: event.topic,
        message: event.message,
        hasAcceptedPrivacyPolicy: event.hasAcceptedPrivacyPolicy,
      ),
    );
    if (requestCallEither.isRight) {
      _trackingDelegate.trackViewEvent('call_request_sent_view');
      emit(state.copyWith(status: BookCallStatus.sent));
      return;
    }

    final failure = requestCallEither.left;
    if (failure is! RequestCallSlotUnavailableFailure) {
      emit(
        state.copyWith(status: BookCallStatus.choosing, sendFailure: failure),
      );
      return;
    }
    // Someone else took the time, so offer the times that are still free.
    final callSlotsEither = await _getCallSlotsUseCase();
    final callSlots = callSlotsEither.isRight
        ? callSlotsEither.right
        : state.callSlots;
    final slotsByDay = callSlots?.slotsByLocalDay ?? const {};
    final selectedDay = state.selectedDay;
    emit(
      BookCallState(
        status: BookCallStatus.choosing,
        callSlots: callSlots,
        selectedDay: slotsByDay.containsKey(selectedDay)
            ? selectedDay
            : slotsByDay.keys.firstOrNull,
        sendFailure: failure,
      ),
    );
  }
}
