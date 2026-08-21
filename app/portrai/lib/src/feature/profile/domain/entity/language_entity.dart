import 'package:equatable/equatable.dart';

class LanguageEntity extends Equatable {
  const LanguageEntity({required this.language, required this.proficiency});

  final String language;
  final String proficiency;

  @override
  List<Object?> get props => [language, proficiency];
}
