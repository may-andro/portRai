import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/testimonial_detail_event.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/testimonial_detail_state.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/tracking/_tracking.dart';
import 'package:portrai/src/utility/screen_tracking_bloc_mixin.dart';
import 'package:tracking/tracking.dart';

@register
class TestimonialDetailBloc
    extends Bloc<TestimonialDetailEvent, TestimonialDetailState>
    with
        ScreenTrackingBlocMixin<
          TestimonialDetailEvent,
          TestimonialDetailState
        > {
  TestimonialDetailBloc(this._trackingDelegate) : super(const LoadingState()) {
    trackScreenViewOn<ScreenVisibleEvent>();
  }

  final TestimonialDetailTrackingDelegate _trackingDelegate;

  @override
  ScreenTrackingDelegate get screenTrackingDelegate => _trackingDelegate;
}
