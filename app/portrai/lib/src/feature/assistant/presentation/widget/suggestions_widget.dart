part of 'assistant_conversation_widget.dart';

class _SuggestionsWidget extends StatelessWidget {
  const _SuggestionsWidget({
    required this.onSelected,
    required this.isBusy,
    this.suggestions,
  });

  final List<String>? suggestions;
  final ValueChanged<String> onSelected;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final suggestions =
        this.suggestions ??
        [
          localizations.assistantSuggestionProjects,
          localizations.assistantSuggestionExperience,
          localizations.assistantSuggestionServices,
          localizations.assistantSuggestionFlutterYears,
          localizations.assistantSuggestionPlayStore,
          localizations.assistantSuggestionLeadership,
        ];
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.space(factor: 3)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSTextWidget(
              localizations.assistantWelcome,
              color: context.colorPalette.neutral.grey9,
              style: context.typography.emphasizedTitleLarge,
              textAlign: TextAlign.center,
            ),
            const DSVerticalSpacerWidget(2),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: context.space(),
              runSpacing: context.space(),
              children: [
                for (final suggestion in suggestions)
                  GestureDetector(
                    onTap: isBusy ? null : () => onSelected(suggestion),
                    child: DSInfoChipWidget(
                      icon: Icons.auto_awesome,
                      label: suggestion,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
