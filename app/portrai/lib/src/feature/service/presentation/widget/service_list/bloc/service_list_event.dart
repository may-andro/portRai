import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ServiceListEvent extends Equatable {
  const ServiceListEvent();

  @override
  List<Object?> get props => [];
}

final class ServiceClickEvent extends ServiceListEvent {
  const ServiceClickEvent({required this.label, required this.serviceTitle});

  /// The tapped element, such as a button or card.
  final String label;

  /// Title of the service that opens.
  final String serviceTitle;

  @override
  List<Object?> get props => [label, serviceTitle];
}
