import 'package:equatable/equatable.dart';

/// How much content a CV keeps so that it fits a single page.
///
/// Level 0 keeps the most content; every next level trims more.
class CvFitLevelEntity extends Equatable {
  const CvFitLevelEntity({
    required this.maxExperiences,
    required this.maxHighlightsPerExperience,
    required this.maxHighlightLength,
    required this.maxProjects,
    required this.maxSkillGroups,
    required this.maxSkillsPerGroup,
    required this.maxEducations,
    required this.maxLanguages,
    required this.maxSummaryLength,
    required this.maxProjectDescriptionLength,
    required this.fontScale,
  });

  static const List<CvFitLevelEntity> levels = [
    CvFitLevelEntity(
      maxExperiences: 3,
      maxHighlightsPerExperience: 4,
      maxHighlightLength: 160,
      maxProjects: 3,
      maxSkillGroups: 6,
      maxSkillsPerGroup: 8,
      maxEducations: 2,
      maxLanguages: 4,
      maxSummaryLength: 400,
      maxProjectDescriptionLength: 180,
      fontScale: 1,
    ),
    CvFitLevelEntity(
      maxExperiences: 3,
      maxHighlightsPerExperience: 3,
      maxHighlightLength: 140,
      maxProjects: 3,
      maxSkillGroups: 6,
      maxSkillsPerGroup: 7,
      maxEducations: 2,
      maxLanguages: 4,
      maxSummaryLength: 320,
      maxProjectDescriptionLength: 150,
      fontScale: 1,
    ),
    CvFitLevelEntity(
      maxExperiences: 3,
      maxHighlightsPerExperience: 3,
      maxHighlightLength: 120,
      maxProjects: 2,
      maxSkillGroups: 5,
      maxSkillsPerGroup: 6,
      maxEducations: 2,
      maxLanguages: 3,
      maxSummaryLength: 260,
      maxProjectDescriptionLength: 120,
      fontScale: 0.95,
    ),
    CvFitLevelEntity(
      maxExperiences: 3,
      maxHighlightsPerExperience: 2,
      maxHighlightLength: 110,
      maxProjects: 2,
      maxSkillGroups: 4,
      maxSkillsPerGroup: 6,
      maxEducations: 2,
      maxLanguages: 3,
      maxSummaryLength: 220,
      maxProjectDescriptionLength: 100,
      fontScale: 0.92,
    ),
    CvFitLevelEntity(
      maxExperiences: 3,
      maxHighlightsPerExperience: 2,
      maxHighlightLength: 90,
      maxProjects: 1,
      maxSkillGroups: 4,
      maxSkillsPerGroup: 5,
      maxEducations: 1,
      maxLanguages: 3,
      maxSummaryLength: 180,
      maxProjectDescriptionLength: 80,
      fontScale: 0.9,
    ),
    CvFitLevelEntity(
      maxExperiences: 2,
      maxHighlightsPerExperience: 2,
      maxHighlightLength: 80,
      maxProjects: 0,
      maxSkillGroups: 3,
      maxSkillsPerGroup: 4,
      maxEducations: 1,
      maxLanguages: 2,
      maxSummaryLength: 140,
      maxProjectDescriptionLength: 60,
      fontScale: 0.85,
    ),
  ];

  final int maxExperiences;
  final int maxHighlightsPerExperience;
  final int maxHighlightLength;
  final int maxProjects;
  final int maxSkillGroups;
  final int maxSkillsPerGroup;
  final int maxEducations;
  final int maxLanguages;
  final int maxSummaryLength;
  final int maxProjectDescriptionLength;

  /// Multiplier applied to every font size of the template.
  final double fontScale;

  @override
  List<Object?> get props => [
    maxExperiences,
    maxHighlightsPerExperience,
    maxHighlightLength,
    maxProjects,
    maxSkillGroups,
    maxSkillsPerGroup,
    maxEducations,
    maxLanguages,
    maxSummaryLength,
    maxProjectDescriptionLength,
    fontScale,
  ];
}
