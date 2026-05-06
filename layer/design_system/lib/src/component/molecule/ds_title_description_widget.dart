import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

/// A title + description text pair used inside card or list items.
///
/// Renders an [emphasizedTitleMedium] heading above an [emphasizedLabelLarge]
/// description, separated by a small gap. Both are constrained to a fixed
/// line count for pixel-perfect layout in grids.
///
/// Set [isCenteredContent] to `true` to centre-align both texts (e.g. for
/// portrait/grid cards). Defaults to left-aligned.
class DSTitleDescriptionWidget extends StatelessWidget {
  const DSTitleDescriptionWidget({
    super.key,
    required this.title,
    required this.description,
    required this.titleMaxLines,
    required this.descriptionMaxLines,
    this.isCenteredContent = false,
  });

  final String title;
  final String description;
  final int titleMaxLines;
  final int descriptionMaxLines;
  final bool isCenteredContent;

  /// Total rendered height for both texts and the separator gap.
  static double getHeight(
    BuildContext context, {
    required int titleMaxLines,
    required int descriptionMaxLines,
  }) {
    return context.getTextHeight(
          context.typography.emphasizedTitleMedium,
          titleMaxLines,
        ) +
        context.space(factor: 0.25) +
        context.getTextHeight(
          context.typography.emphasizedLabelLarge,
          descriptionMaxLines,
        );
  }

  @override
  Widget build(BuildContext context) {
    final crossAxis = isCenteredContent
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final mainAxis = isCenteredContent
        ? MainAxisAlignment.center
        : MainAxisAlignment.start;
    final textAlign = isCenteredContent ? TextAlign.center : TextAlign.start;
    final alignment = isCenteredContent
        ? Alignment.center
        : Alignment.centerLeft;

    return Column(
      crossAxisAlignment: crossAxis,
      mainAxisAlignment: mainAxis,
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(factor: 0.25),
      children: [
        SizedBox(
          height: context.getTextHeight(
            context.typography.emphasizedTitleMedium,
            titleMaxLines,
          ),
          child: Align(
            alignment: alignment,
            child: DSTextWidget(
              title,
              style: context.typography.emphasizedTitleMedium,
              color: context.colorPalette.neutral.grey10,
              textAlign: textAlign,
              maxLines: titleMaxLines,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(
          height: context.getTextHeight(
            context.typography.emphasizedLabelLarge,
            descriptionMaxLines,
          ),
          child: Align(
            alignment: alignment,
            child: DSTextWidget(
              description,
              style: context.typography.emphasizedLabelLarge,
              color: context.colorPalette.neutral.grey8,
              maxLines: descriptionMaxLines,
              textOverflow: TextOverflow.ellipsis,
              textAlign: textAlign,
            ),
          ),
        ),
      ],
    );
  }
}
