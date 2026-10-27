import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_orbit/bloc/expertise_orbit_event.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_orbit/bloc/expertise_orbit_state.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_orbit/tracking/_tracking.dart';

@register
class ExpertiseOrbitBloc
    extends Bloc<ExpertiseOrbitEvent, ExpertiseOrbitState> {
  ExpertiseOrbitBloc(this._trackingDelegate)
    : super(const ExpertiseOrbitState()) {
    on<ExpertiseOrbitClickEvent>(_mapExpertiseOrbitClickEventToState);
  }

  final ExpertiseOrbitTrackingDelegate _trackingDelegate;

  void _mapExpertiseOrbitClickEventToState(
    ExpertiseOrbitClickEvent event,
    Emitter<ExpertiseOrbitState> emit,
  ) => _trackingDelegate.trackExpertiseClick(
    label: event.label,
    expertiseTitle: event.expertiseTitle,
  );
}
