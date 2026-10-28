import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:use_case/use_case.dart';

enum ScheduleAppointmentStatus {
  loading,
  loadFailed,

  /// The visitor is picking a time and filling in their details.
  choosing,
  sending,
  sent,
}

/// Holds no visitor details, since state changes are logged.
@immutable
class ScheduleAppointmentState extends Equatable {
  const ScheduleAppointmentState({
    this.status = ScheduleAppointmentStatus.loading,
    this.appointmentSlots,
    this.selectedDay,
    this.selectedSlot,
    this.loadFailure,
    this.sendFailure,
  });

  final ScheduleAppointmentStatus status;
  final AppointmentSlotsEntity? appointmentSlots;

  /// The local day whose times are shown, at midnight.
  final DateTime? selectedDay;

  /// The start of the chosen slot, or null before the visitor picks one.
  final DateTime? selectedSlot;
  final Failure? loadFailure;

  /// Why the last request was not sent, shown once as a message.
  final Failure? sendFailure;

  ScheduleAppointmentState copyWith({
    ScheduleAppointmentStatus? status,
    AppointmentSlotsEntity? appointmentSlots,
    DateTime? selectedDay,
    DateTime? selectedSlot,
    Failure? loadFailure,
    Failure? sendFailure,
    bool clearSelectedSlot = false,
    bool clearSendFailure = false,
  }) {
    return ScheduleAppointmentState(
      status: status ?? this.status,
      appointmentSlots: appointmentSlots ?? this.appointmentSlots,
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
    appointmentSlots,
    selectedDay,
    selectedSlot,
    loadFailure,
    sendFailure,
  ];
}
