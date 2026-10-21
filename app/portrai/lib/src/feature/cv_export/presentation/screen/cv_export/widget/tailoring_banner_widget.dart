part of 'content_widget.dart';

/// Says which job the CV is tailored for, or why it could not be tailored.
class _TailoringBannerWidget extends StatelessWidget {
  const _TailoringBannerWidget({required this.state});

  final CvExportLoadedState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final tailoringFailure = state.tailoringFailure;
    final tailoringTarget = state.tailoringTarget;
    final isFailed = tailoringFailure != null;
    final tint = isFailed
        ? palette.semantic.warning.color
        : palette.accent.color;

    final String title;
    final String description;
    if (tailoringFailure != null) {
      title = localizations.cvExportTailoringFailed;
      description = FailureTranslator.translate(context, tailoringFailure);
    } else if (tailoringTarget != null) {
      title = localizations.cvExportTailoredFor(
        tailoringTarget.title,
        tailoringTarget.company,
      );
      description = localizations.cvExportTailoredDescription;
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: context.space(factor: 3)),
      child: Container(
        padding: EdgeInsets.all(context.space(factor: 2)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            end: Alignment.bottomRight,
            colors: [tint.withAlpha(30), palette.surface.surface.color],
          ),
          borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
          border: Border.all(color: tint.withAlpha(70)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 1.5),
          children: [
            Icon(
              isFailed
                  ? Icons.info_outline_rounded
                  : Icons.auto_awesome_rounded,
              size: 22,
              color: tint,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: context.space(factor: 0.5),
                children: [
                  DSTextWidget(
                    title,
                    style: context.typography.emphasizedTitleMedium,
                    color: palette.neutral.grey10,
                  ),
                  DSTextWidget(
                    description,
                    style: context.typography.bodyMedium,
                    color: palette.neutral.grey7,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
