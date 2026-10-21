part of 'content_widget.dart';

// Room for the hover lift so it isn't clipped.
const _hoverLift = 8.0;

/// Cards beyond these are already below the first screen, so they appear
/// without the staggered entrance.
const _animatedCardCount = 9;

/// The openings in rows of equal height, built lazily as rows scroll into
/// view.
class _GridWidget extends StatelessWidget {
  const _GridWidget({required this.jobOpenings});

  final List<JobOpeningEntity> jobOpenings;

  @override
  Widget build(BuildContext context) {
    final spacing = context.space(factor: 2);

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.crossAxisExtent);
        final rowCount = (jobOpenings.length / columns).ceil();
        return SliverPadding(
          padding: const EdgeInsets.only(top: _hoverLift),
          sliver: SliverList.separated(
            itemCount: rowCount,
            separatorBuilder: (_, _) => SizedBox(height: spacing),
            itemBuilder: (context, row) => IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: spacing,
                children: [
                  for (var column = 0; column < columns; column++)
                    Expanded(child: _cellAt(row * columns + column)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cellAt(int index) {
    if (index >= jobOpenings.length) return const SizedBox.shrink();

    final card = _JobOpeningCardWidget(jobOpening: jobOpenings[index]);
    if (index >= _animatedCardCount) return card;
    final delay = (100 + index * 80).ms;
    return card
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
