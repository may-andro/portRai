import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

extension CvTemplateLabelExtension on CvTemplate {
  String label(BuildContext context) {
    return switch (this) {
      CvTemplate.sidebar => context.localizations.cvTemplateSidebar,
      CvTemplate.classic => context.localizations.cvTemplateClassic,
      CvTemplate.minimal => context.localizations.cvTemplateMinimal,
      CvTemplate.bold => context.localizations.cvTemplateBold,
    };
  }
}

extension CvAccentLabelExtension on CvAccent {
  String label(BuildContext context) {
    return switch (this) {
      CvAccent.teal => context.localizations.cvAccentTeal,
      CvAccent.indigo => context.localizations.cvAccentIndigo,
      CvAccent.crimson => context.localizations.cvAccentCrimson,
      CvAccent.forest => context.localizations.cvAccentForest,
      CvAccent.charcoal => context.localizations.cvAccentCharcoal,
    };
  }
}

extension CvSectionLabelExtension on CvSection {
  String label(BuildContext context) {
    return switch (this) {
      CvSection.summary => context.localizations.cvSectionSummary,
      CvSection.experience => context.localizations.cvSectionExperience,
      CvSection.projects => context.localizations.cvSectionProjects,
      CvSection.skills => context.localizations.cvSectionSkills,
      CvSection.education => context.localizations.cvSectionEducation,
      CvSection.languages => context.localizations.cvSectionLanguages,
    };
  }
}

extension CvLabelsContextExtension on BuildContext {
  /// The localized texts printed on the CV, in the language of the app.
  CvLabelsEntity get cvLabels {
    return CvLabelsEntity(
      localeCode: languageCode,
      presentLabel: localizations.cvPresent,
      summaryHeading: localizations.cvSectionSummary,
      experienceHeading: localizations.cvSectionExperience,
      projectsHeading: localizations.cvSectionProjects,
      skillsHeading: localizations.cvSectionSkills,
      educationHeading: localizations.cvSectionEducation,
      contactHeading: localizations.cvSectionContact,
      moreExperienceLabel: localizations.cvSeeMoreOnWebsite,
    );
  }
}
