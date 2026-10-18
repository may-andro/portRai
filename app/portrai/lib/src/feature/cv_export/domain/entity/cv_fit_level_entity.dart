import 'package:equatable/equatable.dart';

/// How much content a CV keeps so that it fits a single page.
///
/// Level 0 keeps the most content; every next level trims a little more.
class CvFitLevelEntity extends Equatable {
  const CvFitLevelEntity({
    required this.maxExperiences,
    required this.maxOverviewLength,
    required this.maxProjects,
    required this.maxSkillGroups,
    required this.maxSkillsPerGroup,
    required this.maxEducations,
    required this.maxSummaryLength,
    required this.maxProjectDescriptionLength,
    required this.fontScale,
  });

  /// The level at [progress], from 0 (all content) to 1 (most compact).
  factory CvFitLevelEntity._interpolated(double progress) {
    int between(int full, int compact, [double start = 0]) {
      final stepProgress = ((progress - start) / (1 - start)).clamp(0.0, 1.0);
      return (full + (compact - full) * stepProgress).round();
    }

    return CvFitLevelEntity(
      maxExperiences: progress < 0.9 ? 3 : 2,
      maxOverviewLength: between(500, 110),
      // Projects are cheap and valuable, so they are dropped last.
      maxProjects: between(16, 0, 0.5),
      maxSkillGroups: between(10, 3),
      maxSkillsPerGroup: between(14, 4),
      maxEducations: between(3, 1),
      maxSummaryLength: between(600, 140),
      maxProjectDescriptionLength: between(180, 60),
      fontScale: 1 - 0.15 * progress,
    );
  }

  static const int _levelCount = 32;

  /// A gradual ladder from the full content to the most compact one, so a CV
  /// loses only as much content as it needs to fit a single page.
  static final List<CvFitLevelEntity> levels = List.unmodifiable([
    for (var levelIndex = 0; levelIndex < _levelCount; levelIndex++)
      CvFitLevelEntity._interpolated(levelIndex / (_levelCount - 1)),
  ]);

  final int maxExperiences;
  final int maxOverviewLength;
  final int maxProjects;
  final int maxSkillGroups;
  final int maxSkillsPerGroup;
  final int maxEducations;
  final int maxSummaryLength;
  final int maxProjectDescriptionLength;

  /// Multiplier applied to every font size of the template.
  final double fontScale;

  @override
  List<Object?> get props => [
    maxExperiences,
    maxOverviewLength,
    maxProjects,
    maxSkillGroups,
    maxSkillsPerGroup,
    maxEducations,
    maxSummaryLength,
    maxProjectDescriptionLength,
    fontScale,
  ];
}
