import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/testimonial_detail_bloc.dart';
import 'package:portrai/src/feature/testimonial/presentation/screen/testimonial_detail/bloc/testimonial_detail_state.dart';

extension ContextExtension on BuildContext {
  TestimonialDetailBloc get bloc => read<TestimonialDetailBloc>();

  TestimonialDetailState get state => bloc.state;
}
