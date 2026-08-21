import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object> get props => [];
}

final class ScreenVisibleEvent extends ServicesEvent {}
