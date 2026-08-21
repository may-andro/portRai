import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class TestimonialDetailEvent extends Equatable {
  const TestimonialDetailEvent();

  @override
  List<Object?> get props => [];
}

final class ScreenVisibleEvent extends TestimonialDetailEvent {}
