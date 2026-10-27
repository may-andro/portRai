import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/job_openings_card/bloc/job_openings_card_event.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/job_openings_card/bloc/job_openings_card_state.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/job_openings_card/tracking/_tracking.dart';

@register
class JobOpeningsCardBloc
    extends Bloc<JobOpeningsCardEvent, JobOpeningsCardState> {
  JobOpeningsCardBloc(this._trackingDelegate)
    : super(const JobOpeningsCardState()) {
    on<JobOpeningsCardClickEvent>(_mapJobOpeningsCardClickEventToState);
  }

  final JobOpeningsCardTrackingDelegate _trackingDelegate;

  void _mapJobOpeningsCardClickEventToState(
    JobOpeningsCardClickEvent event,
    Emitter<JobOpeningsCardState> emit,
  ) => _trackingDelegate.trackJobOpeningsClick(event.label);
}
