import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/appointment_requests_card/bloc/appointment_requests_card_bloc.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/appointment_requests_card/bloc/appointment_requests_card_state.dart';

extension ContextExtension on BuildContext {
  AppointmentRequestsCardBloc get bloc => read<AppointmentRequestsCardBloc>();

  AppointmentRequestsCardState get state => bloc.state;
}
