import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/testimonial_detail_event.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/testimonial_detail_state.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/tracking/_tracking.dart';

@register
class TestimonialDetailBloc
    extends Bloc<TestimonialDetailEvent, TestimonialDetailState> {
  TestimonialDetailBloc(this._trackingDelegate) : super(const LoadingState()) {
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
  }

  final TestimonialDetailTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<TestimonialDetailState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }
}
