import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/bloc/service_list_event.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/bloc/service_list_state.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/tracking/_tracking.dart';

@register
class ServiceListBloc extends Bloc<ServiceListEvent, ServiceListState> {
  ServiceListBloc(this._trackingDelegate) : super(const ServiceListState()) {
    on<ServiceClickEvent>(_mapServiceClickEventToState);
  }

  final ServiceListTrackingDelegate _trackingDelegate;

  void _mapServiceClickEventToState(
    ServiceClickEvent event,
    Emitter<ServiceListState> emit,
  ) => _trackingDelegate.trackServiceClick(
    label: event.label,
    serviceTitle: event.serviceTitle,
  );
}
