part of 'content_widget.dart';

class _ModelSetupWidget extends StatelessWidget {
  const _ModelSetupWidget({required this.state});

  final AssistantState state;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final palette = context.colorPalette;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 3)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSIconWidget(
                Icons.offline_bolt_rounded,
                color: palette.brand.primary,
                size: DSIconSize.large,
              ),
              const DSVerticalSpacerWidget(2),
              DSTextWidget(
                localizations.assistantOnDeviceTitle,
                color: palette.neutral.grey9,
                style: context.typography.emphasizedHeadlineSmall,
                textAlign: TextAlign.center,
              ),
              const DSVerticalSpacerWidget(1),
              DSTextWidget(
                localizations.assistantOnDeviceDescription,
                color: palette.neutral.grey7,
                style: context.typography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (state.status case AssistantDownloading(:final progress)) ...[
                const DSVerticalSpacerWidget(3),
                LinearProgressIndicator(
                  color: palette.brand.primary.color,
                  value: progress == 0 ? null : progress / 100,
                ),
                const DSVerticalSpacerWidget(1),
                DSTextWidget(
                  progress == 0
                      ? localizations.assistantPreparingModel
                      : localizations.assistantDownloadProgress(progress),
                  color: palette.neutral.grey7,
                  style: context.typography.labelMedium,
                ),
              ],
              if (state.hasFailed) ...[
                const DSVerticalSpacerWidget(2),
                DSTextWidget(
                  localizations.assistantModelError,
                  color: palette.semantic.error,
                  style: context.typography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
