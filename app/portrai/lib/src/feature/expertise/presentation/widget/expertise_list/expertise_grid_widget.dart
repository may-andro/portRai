part of 'expertise_list_widget.dart';

// Room for the hover lift so it isn't clipped by the section.
const _hoverLift = 8.0;

class _GridWidget extends StatelessWidget {
  const _GridWidget({
    required this.expertises,
    required this.isVisible,
    required this.onClicked,
  });

  final List<ExpertiseEntity> expertises;
  final bool isVisible;
  final ValueChanged<ExpertiseEntity> onClicked;

  @override
  Widget build(BuildContext context) {
    final spacing = context.space(factor: 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        final rows = <Widget>[];

        for (var start = 0; start < expertises.length; start += columns) {
          rows.add(
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
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: _hoverLift),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing,
            children: rows,
          ),
        );
      },
    );
  }

  Widget _cellAt(int index) {
    if (index >= expertises.length) return const SizedBox.shrink();

    return _ExpertiseCardWidget(
          expertise: expertises[index],
          index: index,
          onClicked: onClicked,
        )
        .animate(target: isVisible ? 1 : 0)
        .slideY(
          begin: 0.3,
          duration: 400.ms,
          delay: (100 + index * 100).ms,
          curve: Curves.easeOut,
        )
        .fadeIn(delay: (100 + index * 100).ms, duration: 400.ms);
  }

  int _columnsFor(double width) {
    if (width < 600) return 1;
    if (width < 1000) return 2;
    return 3;
  }
}
