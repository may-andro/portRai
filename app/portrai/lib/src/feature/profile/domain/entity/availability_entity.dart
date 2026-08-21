import 'package:equatable/equatable.dart';

class AvailabilityEntity extends Equatable {
  const AvailabilityEntity({
    required this.status,
    required this.workType,
    required this.openToRelocate,
    required this.preferredProjectDuration,
    required this.hourlyRate,
    required this.availability,
  });

  final String status;
  final String workType;
  final bool openToRelocate;
  final String preferredProjectDuration;
  final String hourlyRate;
  final String availability;

  @override
  List<Object?> get props => [
    status,
    workType,
    openToRelocate,
    preferredProjectDuration,
    hourlyRate,
    availability,
  ];
}
