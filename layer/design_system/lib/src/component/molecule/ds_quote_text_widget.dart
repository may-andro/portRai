import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/extension/ds_color_roles_extension.dart';
import 'package:flutter/material.dart';

/// A blockquote-style text widget: an opening `❝` glyph in the accent colour
/// followed by the [text] body capped at [maxLines].
///
/// Supports fixed-height layouts via [getHeight].
class DSQuoteTextWidget extends StatelessWidget {
  const DSQuoteTextWidget({
    super.key,
    required this.text,
    required this.maxLines,
  });

  final String text;
  final int maxLines;

  static double getHeight(BuildContext context, {required int maxLines}) {
    return context.getTextHeight(
      context.typography.emphasizedLabelLarge,
      maxLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getHeight(context, maxLines: maxLines),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSTextWidget(
            '❝ ',
            style: context.typography.emphasizedDisplaySmall,
            color: context.colorPalette.accent,
          ),
          Expanded(
            child: DSTextWidget(
              text,
              style: context.typography.emphasizedLabelLarge,
              color: context.colorPalette.neutral.grey9,
              maxLines: maxLines,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
