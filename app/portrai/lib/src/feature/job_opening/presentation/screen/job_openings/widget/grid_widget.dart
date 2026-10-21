part of 'content_widget.dart';

// Room for the hover lift so it isn't clipped.
const _hoverLift = 8.0;

/// Cards beyond these are already below the first screen, so they appear
/// without the staggered entrance.
const _animatedCardCount = 9;

/// The openings in rows of equal height, built lazily as rows scroll into
/// view. The first cards play a staggered entrance once; rows rebuilt when
/// scrolled back into view appear as they are.
class _GridWidget extends StatefulWidget {
  const _GridWidget({required this.jobOpenings});

  final List<JobOpeningEntity> jobOpenings;

  @override
  State<_GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<_GridWidget> {
  /// Set after the first frame, so only the first build animates.
  bool _hasEntered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hasEntered = true);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.space(factor: 2);
    final jobOpenings = widget.jobOpenings;

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
    final jobOpenings = widget.jobOpenings;
    if (index >= jobOpenings.length) return const SizedBox.shrink();

    // Every card keeps the same wrapper, so a rebuild never remounts one;
    // cards that should not play start at the end of the entrance.
    final isPlaying = !_hasEntered && index < _animatedCardCount;
    final delay = (100 + min(index, _animatedCardCount) * 80).ms;
    return _JobOpeningCardWidget(jobOpening: jobOpenings[index])
        .animate(autoPlay: isPlaying, value: isPlaying ? null : 1)
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
