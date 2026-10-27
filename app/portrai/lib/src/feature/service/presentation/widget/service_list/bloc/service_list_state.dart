import 'package:equatable/equatable.dart';

/// The list shows the services it is given, so its bloc only handles taps
/// and keeps no state of its own.
final class ServiceListState extends Equatable {
  const ServiceListState();

  @override
  List<Object?> get props => [];
}
