import 'package:equatable/equatable.dart';

class CvLanguageEntity extends Equatable {
  const CvLanguageEntity({required this.name, required this.proficiency});

  final String name;
  final String proficiency;

  @override
  List<Object?> get props => [name, proficiency];
}
