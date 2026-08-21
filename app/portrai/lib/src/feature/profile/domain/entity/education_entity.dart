import 'package:equatable/equatable.dart';

class EducationEntity extends Equatable {
  const EducationEntity({
    required this.institution,
    required this.degree,
    required this.field,
    required this.startDate,
    required this.endDate,
    required this.image,
    required this.url,
    required this.location,
  });

  final String institution;
  final String degree;
  final String field;
  final String startDate;
  final String endDate;
  final String image;
  final String url;
  final String location;

  @override
  List<Object?> get props => [
    institution,
    degree,
    field,
    startDate,
    endDate,
    image,
    url,
    location,
  ];
}
