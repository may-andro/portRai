import 'package:equatable/equatable.dart';

class CvExperienceEntity extends Equatable {
  const CvExperienceEntity({
    required this.position,
    required this.company,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.overview,
    this.detailedOverview = '',
    this.url,
  });

  final String position;
  final String company;
  final String location;
  final DateTime startDate;

  /// `null` means the position is current.
  final DateTime? endDate;

  /// A short paragraph describing the role.
  final String overview;

  /// A longer description, used instead of [overview] when there is room.
  final String detailedOverview;

  /// The employer website; makes the company clickable when present.
  final String? url;

  @override
  List<Object?> get props => [
    position,
    company,
    location,
    startDate,
    endDate,
    overview,
    detailedOverview,
    url,
  ];
}
