import 'package:equatable/equatable.dart';

class CvEducationEntity extends Equatable {
  const CvEducationEntity({
    required this.degree,
    required this.institution,
    required this.period,
  });

  final String degree;
  final String institution;
  final String period;

  @override
  List<Object?> get props => [degree, institution, period];
}
