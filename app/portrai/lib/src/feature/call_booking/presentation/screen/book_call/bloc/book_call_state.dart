import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/call_booking/domain/_domain.dart';
import 'package:use_case/use_case.dart';

enum BookCallStatus {
  loading,
  loadFailed,

  /// The visitor is picking a time and filling in their details.
  choosing,
  sending,
  sent,
}

/// Holds no visitor details, since state changes are logged.
@immutable
class BookCallState extends Equatable {
  const BookCallState({
    this.status = BookCallStatus.loading,
    this.callSlots,
    this.selectedDay,
    this.selectedSlot,
    this.loadFailure,
    this.sendFailure,
  });

  final BookCallStatus status;
  final CallSlotsEntity? callSlots;

  /// The local day whose times are shown, at midnight.
  final DateTime? selectedDay;

  /// The start of the chosen slot, or null before the visitor picks one.
  final DateTime? selectedSlot;
  final Failure? loadFailure;

  /// Why the last request was not sent, shown once as a message.
  final Failure? sendFailure;

  BookCallState copyWith({
    BookCallStatus? status,
    CallSlotsEntity? callSlots,
    DateTime? selectedDay,
    DateTime? selectedSlot,
    Failure? loadFailure,
    Failure? sendFailure,
    bool clearSelectedSlot = false,
    bool clearSendFailure = false,
  }) {
    return BookCallState(
      status: status ?? this.status,
      callSlots: callSlots ?? this.callSlots,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedSlot: clearSelectedSlot
          ? null
          : selectedSlot ?? this.selectedSlot,
      loadFailure: loadFailure ?? this.loadFailure,
      sendFailure: clearSendFailure ? null : sendFailure ?? this.sendFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    callSlots,
    selectedDay,
    selectedSlot,
    loadFailure,
    sendFailure,
  ];
}
