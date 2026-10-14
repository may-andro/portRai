import 'package:equatable/equatable.dart';

class SkillEntity extends Equatable {
  const SkillEntity({
    required this.name,
    this.description,
    this.level,
    this.years,
    this.lastUsed,
  });

  final String name;

  /// Short text explaining what the skill covers.
  final String? description;

  /// One of `expert`, `advanced`, `intermediate` or `familiar`.
  final String? level;

  /// Years of hands-on use.
  final int? years;

  /// Calendar year the skill was last used.
  final int? lastUsed;

  @override
  List<Object?> get props => [name, description, level, years, lastUsed];
}
