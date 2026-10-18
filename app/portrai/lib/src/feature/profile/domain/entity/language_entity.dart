import 'package:equatable/equatable.dart';

class LanguageEntity extends Equatable {
  const LanguageEntity({
    required this.language,
    required this.proficiency,
    this.code,
  });

  final String language;
  final String proficiency;
  final String? code;

  @override
  List<Object?> get props => [language, proficiency, code];
}
