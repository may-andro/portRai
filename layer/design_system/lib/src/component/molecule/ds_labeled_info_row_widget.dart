import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

/// A labelled info row composed of:
/// - a [icon] centred in a brand `primaryContainer` circle
/// - a two-line [label] / [value] column
/// - an optional trailing chevron when [onTap] is provided
///
/// Commonly used for contact info, metadata, settings entries, etc.
class DSLabeledInfoRowWidget extends StatelessWidget {
  const DSLabeledInfoRowWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      spacing: context.space(factor: 1.5),
      children: [
        Container(
          padding: EdgeInsets.all(context.space()),
          decoration: BoxDecoration(
            color: context.colorPalette.brand.primaryContainer.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: context.colorPalette.brand.primary.color,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(factor: 0.25),
            children: [
              DSTextWidget(
                label,
                style: context.typography.bodySmall,
                color: context.colorPalette.neutral.grey7,
              ),
              DSTextWidget(
                value,
                style: context.typography.emphasizedBodyMedium,
                color: context.colorPalette.neutral.grey9,
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: context.colorPalette.neutral.grey7.color,
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel1.value),
        child: content,
      );
    }

    return content;
  }
}
