part of 'content_widget.dart';

/// Generated insights on preparing for the job, created on request.
class _InsightsWidget extends StatelessWidget {
  const _InsightsWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobOpeningBloc, JobOpeningState>(
      buildWhen: (previous, current) =>
          previous.insightsStatus != current.insightsStatus ||
          previous.insightsController != current.insightsController ||
          previous.insightsSurfaceIds != current.insightsSurfaceIds ||
          previous.insightsFailure != current.insightsFailure,
      builder: (context, state) {
        final controller = state.insightsController;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: context.space(factor: 2),
          children: [
            if (state.insightsStatus == JobOpeningInsightsStatus.failed)
              DSErrorCardWidget(
                message: state.insightsFailure == null
                    ? null
                    : FailureTranslator.translate(
                        context,
                        state.insightsFailure!,
                      ),
                onRetryClicked: () =>
                    context.bloc.add(const GenerateInsightsClickEvent()),
              )
            else
              _InsightsPromptWidget(status: state.insightsStatus),
            if (controller != null)
              for (final surfaceId in state.insightsSurfaceIds)
                _InsightsSurfaceWidget(
                  key: ValueKey(surfaceId),
                  genuiController: controller,
                  surfaceId: surfaceId,
                ),
          ],
        );
      },
    );
  }
}

class _InsightsPromptWidget extends StatelessWidget {
  const _InsightsPromptWidget({required this.status});

  final JobOpeningInsightsStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final accent = palette.accent.color;
    final isGenerating = status == JobOpeningInsightsStatus.generating;
    final isReady = status == JobOpeningInsightsStatus.ready;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 0.75),
      children: [
        DSTextWidget(
          isGenerating
              ? localizations.jobOpeningInsightsGenerating
              : localizations.jobOpeningInsightsPromptTitle,
          style: context.typography.emphasizedTitleLarge,
          color: palette.neutral.grey10,
        ),
        DSTextWidget(
          localizations.jobOpeningInsightsPromptDescription,
          style: context.typography.bodyMedium,
          color: palette.neutral.grey7,
        ),
      ],
    );
    final Widget action = isGenerating
        ? DSLoadingWidget(
            style: DSLoadingStyle.lottie,
            size: max(context.shortestSide * 0.1, context.space(factor: 2)),
          )
        : DSButtonWidget(
            label: isReady
                ? localizations.jobOpeningInsightsRegenerate
                : localizations.jobOpeningInsightsGenerate,
            icon: isReady ? Icons.refresh_rounded : Icons.auto_awesome_rounded,
            variant: isReady
                ? DSButtonVariant.secondary
                : DSButtonVariant.primary,
            isExpanded: false,
            onPressed: () =>
                context.bloc.add(const GenerateInsightsClickEvent()),
          );

    return Container(
      padding: EdgeInsets.all(context.space(factor: 2.5)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          end: Alignment.bottomRight,
          colors: [accent.withAlpha(28), palette.surface.surface.color],
        ),
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
        border: Border.all(color: accent.withAlpha(60)),
      ),
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(factor: 2),
              children: [copy, action],
            )
          : Row(
              spacing: context.space(factor: 3),
              children: [
                Expanded(child: copy),
                action,
              ],
            ),
    );
  }
}

class _InsightsSurfaceWidget extends StatefulWidget {
  const _InsightsSurfaceWidget({
    super.key,
    required this.genuiController,
    required this.surfaceId,
  });

  final AssistantGenuiController genuiController;
  final String surfaceId;

  @override
  State<_InsightsSurfaceWidget> createState() => _InsightsSurfaceWidgetState();
}

class _InsightsSurfaceWidgetState extends State<_InsightsSurfaceWidget> {
  late void Function() _releaseSurface;

  @override
  void initState() {
    super.initState();
    _releaseSurface = widget.genuiController.acquireSurface();
  }

  @override
  void didUpdateWidget(covariant _InsightsSurfaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.genuiController, widget.genuiController)) {
      _releaseSurface();
      _releaseSurface = widget.genuiController.acquireSurface();
    }
  }

  @override
  void dispose() {
    _releaseSurface();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Surface(
    surfaceContext: widget.genuiController.surfaceController.contextFor(
      widget.surfaceId,
    ),
  );
}
