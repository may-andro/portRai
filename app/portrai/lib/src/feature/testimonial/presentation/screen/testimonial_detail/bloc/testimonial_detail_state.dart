import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/testimonial/domain/_domain.dart';

@immutable
sealed class TestimonialDetailState extends Equatable {
  const TestimonialDetailState();

  @override
  List<Object?> get props => [];
}

final class LoadingState extends TestimonialDetailState {
  const LoadingState();
}

final class LoadedState extends TestimonialDetailState {
  const LoadedState(this.testimonial);

  final TestimonialEntity testimonial;

  @override
  List<Object?> get props => [testimonial];
}
