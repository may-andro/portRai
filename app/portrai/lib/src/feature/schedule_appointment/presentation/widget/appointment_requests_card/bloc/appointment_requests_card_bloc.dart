import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/appointment_requests_card/bloc/appointment_requests_card_event.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/appointment_requests_card/bloc/appointment_requests_card_state.dart';
import 'package:portrai/src/feature/schedule_appointment/presentation/widget/appointment_requests_card/tracking/_tracking.dart';

@register
class AppointmentRequestsCardBloc
    extends Bloc<AppointmentRequestsCardEvent, AppointmentRequestsCardState> {
  AppointmentRequestsCardBloc(this._trackingDelegate)
    : super(const AppointmentRequestsCardState()) {
    on<AppointmentRequestsCardClickEvent>(
      _mapAppointmentRequestsCardClickEventToState,
    );
  }

  final AppointmentRequestsCardTrackingDelegate _trackingDelegate;

  void _mapAppointmentRequestsCardClickEventToState(
    AppointmentRequestsCardClickEvent event,
    Emitter<AppointmentRequestsCardState> emit,
  ) => _trackingDelegate.trackAppointmentRequestsClick(event.label);
}
