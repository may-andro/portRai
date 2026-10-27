import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/bloc/experience_list_event.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/bloc/experience_list_state.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/tracking/_tracking.dart';

@register
class ExperienceListBloc
    extends Bloc<ExperienceListEvent, ExperienceListState> {
  ExperienceListBloc(this._trackingDelegate)
    : super(const ExperienceListState()) {
    on<ExperienceClickEvent>(_mapExperienceClickEventToState);
  }

  final ExperienceListTrackingDelegate _trackingDelegate;

  void _mapExperienceClickEventToState(
    ExperienceClickEvent event,
    Emitter<ExperienceListState> emit,
  ) => _trackingDelegate.trackExperienceClick(
    label: event.label,
    experienceId: event.experienceId,
  );
}
