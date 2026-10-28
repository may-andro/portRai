import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/bloc/schedule_appointment_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/schedule_appointment/bloc/schedule_appointment_state.dart';

extension ContextExtension on BuildContext {
  ScheduleAppointmentBloc get bloc => read<ScheduleAppointmentBloc>();

  ScheduleAppointmentState get state => bloc.state;
}
