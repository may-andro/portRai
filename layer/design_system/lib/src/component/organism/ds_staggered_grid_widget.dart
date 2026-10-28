import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// A masonry grid that sizes itself to its items and never scrolls.
///
/// When the grid is too narrow for the gaps between [crossAxisCount] columns,
/// for example while a parent animates its width, it shows fewer columns so
/// that no column gets a negative width.
class DSStaggeredGridWidget extends StatelessWidget {
  const DSStaggeredGridWidget({
    required this.crossAxisCount,
    required this.itemCount,
    required this.itemBuilder,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    super.key,
  });

  final int crossAxisCount;
  final int itemCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// The most columns of at most [crossAxisCount] whose gaps fit in [width].
  static int fittingColumnCount({
    required double width,
    required int crossAxisCount,
    required double crossAxisSpacing,
  }) {
    var count = crossAxisCount;
    while (count > 1 && width - crossAxisSpacing * (count - 1) <= 0) {
      count--;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = fittingColumnCount(
          width: constraints.maxWidth,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
        );
        return MasonryGridView.count(
          mainAxisSpacing: mainAxisSpacing,
          // One column has no gaps, so no spacing can make it negative.
          crossAxisSpacing: columnCount > 1 ? crossAxisSpacing : 0,
          crossAxisCount: columnCount,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
          clipBehavior: Clip.antiAlias,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
        );
      },
    );
  }
}
