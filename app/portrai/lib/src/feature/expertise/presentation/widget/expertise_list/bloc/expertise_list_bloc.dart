import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_list/bloc/expertise_list_event.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_list/bloc/expertise_list_state.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_list/tracking/_tracking.dart';

@register
class ExpertiseListBloc extends Bloc<ExpertiseListEvent, ExpertiseListState> {
  ExpertiseListBloc(this._trackingDelegate)
    : super(const ExpertiseListState()) {
    on<ExpertiseClickEvent>(_mapExpertiseClickEventToState);
  }

  final ExpertiseListTrackingDelegate _trackingDelegate;

  void _mapExpertiseClickEventToState(
    ExpertiseClickEvent event,
    Emitter<ExpertiseListState> emit,
  ) => _trackingDelegate.trackExpertiseClick(event.expertiseTitle);
}
