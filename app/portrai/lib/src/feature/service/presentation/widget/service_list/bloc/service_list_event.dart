import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ServiceListEvent extends Equatable {
  const ServiceListEvent();

  @override
  List<Object?> get props => [];
}

final class ServiceClickEvent extends ServiceListEvent {
  const ServiceClickEvent(this.serviceTitle);

  final String serviceTitle;

  @override
  List<Object?> get props => [serviceTitle];
}
