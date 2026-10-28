import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/bloc/schedule_appointment_entry_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/schedule_appointment_entry/bloc/schedule_appointment_entry_state.dart';

extension ContextExtension on BuildContext {
  ScheduleAppointmentEntryBloc get bloc => read<ScheduleAppointmentEntryBloc>();

  ScheduleAppointmentEntryState get state => bloc.state;
}
