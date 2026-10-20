import 'package:flutter/widgets.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/user/user.dart';

extension UserRoleSuggestionsExtension on UserRole? {
  /// Starter questions that match what the role cares about; null keeps the
  /// general portfolio questions.
  List<String>? assistantSuggestions(BuildContext context) {
    final localizations = context.localizations;
    return switch (this) {
      UserRole.developer => [
        localizations.assistantSuggestionProjects,
        localizations.assistantSuggestionTechStack,
        localizations.assistantSuggestionArchitecture,
        localizations.assistantSuggestionPlayStore,
      ],
      UserRole.recruiter => [
        localizations.assistantSuggestionAvailability,
        localizations.assistantSuggestionExperience,
        localizations.assistantSuggestionFlutterYears,
        localizations.assistantSuggestionLeadership,
        localizations.assistantSuggestionContact,
      ],
      UserRole.other || null => null,
    };
  }
}
