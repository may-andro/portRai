import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/_domain.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/bloc/schedule_appointment_entry_event.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/bloc/schedule_appointment_entry_state.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/tracking/_tracking.dart';

@register
class ScheduleAppointmentEntryBloc
    extends Bloc<ScheduleAppointmentEntryEvent, ScheduleAppointmentEntryState> {
  ScheduleAppointmentEntryBloc(
    this._isScheduleAppointmentAvailableUseCase,
    this._trackingDelegate,
  ) : super(const ScheduleAppointmentEntryState()) {
    on<LoadScheduleAppointmentEntryEvent>(
      _mapLoadScheduleAppointmentEntryEventToState,
    );
    on<ScheduleAppointmentClickEvent>(_mapScheduleAppointmentClickEventToState);
  }

  final IsScheduleAppointmentAvailableUseCase
  _isScheduleAppointmentAvailableUseCase;
  final ScheduleAppointmentEntryTrackingDelegate _trackingDelegate;

  Future<void> _mapLoadScheduleAppointmentEntryEventToState(
    LoadScheduleAppointmentEntryEvent event,
    Emitter<ScheduleAppointmentEntryState> emit,
  ) async {
    final isAvailableEither = await _isScheduleAppointmentAvailableUseCase();
    emit(
      ScheduleAppointmentEntryState(
        isAvailable: isAvailableEither.isRight && isAvailableEither.right,
      ),
    );
  }

  void _mapScheduleAppointmentClickEventToState(
    ScheduleAppointmentClickEvent event,
    Emitter<ScheduleAppointmentEntryState> emit,
  ) => _trackingDelegate.trackScheduleAppointmentClick(
    label: event.label,
    topic: event.topic,
  );
}
