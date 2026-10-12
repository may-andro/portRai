import 'package:equatable/equatable.dart';

class SkillEntity extends Equatable {
  const SkillEntity({
    required this.name,
    this.level,
    this.years,
    this.lastUsed,
  });

  final String name;

  /// One of `expert`, `advanced`, `intermediate` or `familiar`.
  final String? level;

  /// Years of hands-on use.
  final int? years;

  /// Calendar year the skill was last used.
  final int? lastUsed;

  @override
  List<Object?> get props => [name, level, years, lastUsed];
}
