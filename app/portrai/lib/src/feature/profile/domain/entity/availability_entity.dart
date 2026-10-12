import 'package:equatable/equatable.dart';

class AvailabilityEntity extends Equatable {
  const AvailabilityEntity({
    required this.status,
    required this.workType,
    required this.openToRelocate,
    required this.preferredProjectDuration,
    required this.hourlyRate,
    required this.availability,
    this.noticePeriod,
    this.workAuthorization,
    this.note,
  });

  final String status;
  final String workType;
  final bool openToRelocate;
  final String preferredProjectDuration;
  final String hourlyRate;
  final String availability;
  final String? noticePeriod;
  final String? workAuthorization;
  final String? note;

  @override
  List<Object?> get props => [
    status,
    workType,
    openToRelocate,
    preferredProjectDuration,
    hourlyRate,
    availability,
    noticePeriod,
    workAuthorization,
    note,
  ];
}
