import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/appointment_requests_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/screen/appointment_requests/bloc/appointment_requests_state.dart';

extension ContextExtension on BuildContext {
  AppointmentRequestsBloc get bloc => read<AppointmentRequestsBloc>();

  AppointmentRequestsState get state => bloc.state;
}
