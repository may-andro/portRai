import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_accent.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_section.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_template.dart';

class CvOptionsEntity extends Equatable {
  const CvOptionsEntity({
    this.template = CvTemplate.sidebar,
    this.accent = CvAccent.teal,
    this.isPhotoIncluded = false,
    this.photoUrl,
    this.sections = const {...CvSection.values},
  });

  final CvTemplate template;
  final CvAccent accent;
  final bool isPhotoIncluded;

  /// The chosen photo; the document's default photo when `null`.
  final String? photoUrl;
  final Set<CvSection> sections;

  CvOptionsEntity copyWith({
    CvTemplate? template,
    CvAccent? accent,
    bool? isPhotoIncluded,
    String? photoUrl,
    Set<CvSection>? sections,
  }) {
    return CvOptionsEntity(
      template: template ?? this.template,
      accent: accent ?? this.accent,
      isPhotoIncluded: isPhotoIncluded ?? this.isPhotoIncluded,
      photoUrl: photoUrl ?? this.photoUrl,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    template,
    accent,
    isPhotoIncluded,
    photoUrl,
    sections,
  ];
}
