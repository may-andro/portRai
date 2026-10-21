import 'package:equatable/equatable.dart';

/// How to tailor a CV for a job. It only rewrites the summary and reorders
/// existing content, so a tailored CV holds no facts the portfolio lacks.
class CvTailoringEntity extends Equatable {
  const CvTailoringEntity({
    required this.summary,
    this.projectOrder = const [],
    this.skillGroupOrder = const [],
    this.prioritizedSkills = const [],
  });

  final String summary;

  /// Project indexes, most relevant first.
  final List<int> projectOrder;

  /// Skill group indexes, most relevant first.
  final List<int> skillGroupOrder;

  /// Skills to move to the front of their group, by name.
  final List<String> prioritizedSkills;

  @override
  List<Object?> get props => [
    summary,
    projectOrder,
    skillGroupOrder,
    prioritizedSkills,
  ];
}
