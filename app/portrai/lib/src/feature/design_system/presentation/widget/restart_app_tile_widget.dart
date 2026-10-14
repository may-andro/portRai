part of 'design_system_selector_widget.dart';

class _RestartAppTileWidget extends StatelessWidget {
  const _RestartAppTileWidget({
    required this.isRestartRequired,
    required this.onRestart,
  });

  final bool isRestartRequired;
  final Future<void> Function() onRestart;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: Padding(
        padding: EdgeInsets.all(context.space()),
        child: Row(
          children: [
            DSIconWidget(
              Icons.restart_alt_rounded,
              color: context.colorPalette.neutral.grey9,
              size: DSIconSize.small,
            ),
            const DSHorizontalSpacerWidget(0.5),
            Expanded(
              child: DSTextWidget(
                context.localizations.developerMenuDesignSystemRestartRequired,
                color: context.colorPalette.neutral.grey9,
                style: context.typography.labelMedium,
              ),
            ),
            const DSHorizontalSpacerWidget(2),
            DSButtonWidget(
              label: context.localizations.featureFlagRestartButton,
              size: DSButtonSize.small,
              variant: DSButtonVariant.text,
              onPressed: () async {
                await onRestart();
              },
            ),
          ],
        ),
      ),
      secondChild: const SizedBox.shrink(),
      crossFadeState: isRestartRequired
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      alignment: Alignment.bottomCenter,
      duration: const Duration(milliseconds: 300),
    );
  }
}
