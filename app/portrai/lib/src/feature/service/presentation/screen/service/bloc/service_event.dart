import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object> get props => [];
}

final class ScreenVisibleEvent extends ServiceEvent {}
