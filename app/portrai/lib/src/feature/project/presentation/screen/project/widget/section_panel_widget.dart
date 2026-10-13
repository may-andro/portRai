import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Open editorial section: gradient rail beside the title, no boxed card.
class ProjectSectionPanelWidget extends StatelessWidget {
  const ProjectSectionPanelWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.eyebrow = false,
  });

  /// Small-caps label without the side rail, for lead-in sections.
  final bool eyebrow;
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    if (eyebrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 1.5),
        children: [
          Row(
            spacing: context.space(),
            children: [
              Icon(icon, size: 16, color: accent),
              DSTextWidget(
                title,
                style: context.typography.emphasizedLabelMedium,
                color: palette.neutral.grey7,
              ),
              Expanded(
                child: Divider(color: palette.neutral.grey3.color, height: 1),
              ),
            ],
          ),
          child,
        ],
      ).animate().fadeIn(duration: 500.ms);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 2),
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accent, palette.brand.tertiary.color.withAlpha(0)],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: context.space(factor: 2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: context.space(factor: 2),
                children: [
                  Row(
                    spacing: context.space(factor: 1.5),
                    children: [
                      Icon(icon, size: 22, color: accent),
                      Expanded(
                        child: DSTextWidget(
                          title,
                          style: context.typography.emphasizedTitleLarge,
                          color: palette.neutral.grey10,
                        ),
                      ),
                    ],
                  ),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.03, end: 0);
  }
}

/// Numbered wins: big faint index, hairline separators.
class ProjectAchievementListWidget extends StatelessWidget {
  const ProjectAchievementListWidget({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Column(
      children: [
        for (final (index, item) in items.indexed)
          Container(
                padding: EdgeInsets.symmetric(vertical: context.space()),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: index == 0
                          ? Colors.transparent
                          : palette.neutral.grey3.color,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: context.space(factor: 1.5),
                  children: [
                    SizedBox(
                      width: 40,
                      child: DSTextWidget(
                        (index + 1).toString().padLeft(2, '0'),
                        style: context.typography.emphasizedTitleLarge,
                        color: DSColor(
                          palette.brand.primary.color.withAlpha(150).toARGB32(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: DSTextWidget(
                        item,
                        style: context.typography.bodyMedium,
                        color: palette.neutral.grey10,
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: (index * 80).ms)
              .fadeIn()
              .slideX(begin: 0.04, end: 0),
      ],
    );
  }
}

/// Technologies as outlined tiles with a colour dot (no filled blue tags).
class ProjectTechListWidget extends StatelessWidget {
  const ProjectTechListWidget({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final colors = [
      palette.brand.primary.color,
      palette.brand.tertiary.color,
      palette.brand.secondary.color,
    ];
    return Wrap(
      spacing: context.space(),
      runSpacing: context.space(),
      children: [
        for (final (index, item) in items.indexed)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.space(factor: 1.25),
              vertical: context.space(factor: 0.75),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.neutral.grey3.color),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: context.space(),
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[index % colors.length],
                  ),
                ),
                Flexible(
                  child: DSTextWidget(
                    item,
                    style: context.typography.bodySmall,
                    color: palette.neutral.grey9,
                  ),
                ),
              ],
            ),
          ).animate(delay: (index * 30).ms).fadeIn().slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

/// Features as small content-sized pills with a bolt accent.
class ProjectFeatureListWidget extends StatelessWidget {
  const ProjectFeatureListWidget({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    return Wrap(
      spacing: context.space(factor: 0.75),
      runSpacing: context.space(factor: 0.75),
      children: [
        for (final (index, item) in items.indexed)
          Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(),
                  vertical: context.space(factor: 0.5),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: LinearGradient(
                    colors: [accent.withAlpha(30), accent.withAlpha(8)],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: context.space(factor: 0.5),
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: accent),
                    Flexible(
                      child: DSTextWidget(
                        item,
                        style: context.typography.bodySmall,
                        color: palette.neutral.grey10,
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: (index * 40).ms)
              .fadeIn()
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
      ],
    );
  }
}
