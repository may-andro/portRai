import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Pinned title bar shown at the top of mobile and tablet screens. Follows the
/// theme background unless colors are given.
class PageAppBarWidget extends StatelessWidget {
  const PageAppBarWidget({
    required this.title,
    this.backgroundColor,
    this.titleColor,
    super.key,
  });

  final String title;
  final Color? backgroundColor;
  final DSColor? titleColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final resolvedTitleColor = titleColor ?? palette.neutral.grey9;
    return SliverAppBar(
      pinned: true,
      elevation: context.dimen.elevationNone.value,
      scrolledUnderElevation: context.dimen.elevationNone.value,
      backgroundColor: backgroundColor ?? palette.background.color,
      surfaceTintColor: palette.neutral.transparent.color,
      foregroundColor: resolvedTitleColor.color,
      automaticallyImplyLeading: !kIsWeb,
      centerTitle: true,
      title: DSTextWidget(
        title,
        color: resolvedTitleColor,
        style: kIsWeb
            ? context.typography.emphasizedTitleLarge
            : context.typography.emphasizedTitleMedium,
        maxLines: 1,
      ),
    );
  }
}
