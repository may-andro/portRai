import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/service_event.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/service_state.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class ServiceBloc extends Bloc<ServiceEvent, ServiceState>
    with ScreenTrackingBlocMixin<ServiceEvent, ServiceState> {
  ServiceBloc(this._trackingDelegate) : super(const ServiceState()) {
    trackScreenViewOn<ScreenVisibleEvent>();
  }

  final ServiceTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;
}
