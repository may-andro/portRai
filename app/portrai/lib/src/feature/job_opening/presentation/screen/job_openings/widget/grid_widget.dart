part of 'content_widget.dart';

// Room for the hover lift so it isn't clipped.
const _hoverLift = 8.0;

class _GridWidget extends StatelessWidget {
  const _GridWidget({required this.jobOpenings});

  final List<JobOpeningEntity> jobOpenings;

  @override
  Widget build(BuildContext context) {
    final spacing = context.space(factor: 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        return Padding(
          padding: const EdgeInsets.only(top: _hoverLift),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing,
            children: [
              for (var start = 0; start < jobOpenings.length; start += columns)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: spacing,
                    children: [
                      for (var column = 0; column < columns; column++)
                        Expanded(child: _cellAt(start + column)),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _cellAt(int index) {
    if (index >= jobOpenings.length) return const SizedBox.shrink();

    final delay = (100 + index * 80).ms;
    return _JobOpeningCardWidget(jobOpening: jobOpenings[index])
        .animate()
        .slideY(
          begin: 0.2,
          duration: 400.ms,
          delay: delay,
          curve: Curves.easeOut,
        )
        .fadeIn(delay: delay, duration: 400.ms);
  }

  int _columnsFor(double width) {
    if (width < 640) return 1;
    if (width < 980) return 2;
    return 3;
  }
}
