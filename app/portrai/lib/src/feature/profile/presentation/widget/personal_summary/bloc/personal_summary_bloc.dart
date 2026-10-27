import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/bloc/personal_summary_event.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/bloc/personal_summary_state.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/tracking/_tracking.dart';

@register
class PersonalSummaryBloc
    extends Bloc<PersonalSummaryEvent, PersonalSummaryState> {
  PersonalSummaryBloc(this._trackingDelegate)
    : super(const PersonalSummaryState()) {
    on<ViewProfileClickEvent>(_mapViewProfileClickEventToState);
  }

  final PersonalSummaryTrackingDelegate _trackingDelegate;

  void _mapViewProfileClickEventToState(
    ViewProfileClickEvent event,
    Emitter<PersonalSummaryState> emit,
  ) => _trackingDelegate.trackViewProfileClick();
}
