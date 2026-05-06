import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

/// A compact icon + label pill badge that uses the brand secondary container
/// colour scheme. Commonly used to surface meta-info (dates, location, status,
/// role, etc.) on detail screens.
class DSInfoChipWidget extends StatelessWidget {
  const DSInfoChipWidget({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: context.isDesktop ? 1.0 : 1.5),
        vertical: context.space(factor: context.isDesktop ? 0.5 : 0.75),
      ),
      decoration: BoxDecoration(
        color: context.colorPalette.brand.secondaryContainer.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.75),
        children: [
          DSIconWidget(
            icon,
            color: context.colorPalette.brand.onSecondaryContainer,
            size: DSIconSize.small,
          ),
          DSTextWidget(
            label,
            style: context.typography.labelMedium,
            color: context.colorPalette.brand.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}
