import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/extension/project_date_range_extension.dart';

/// App-store style header: a big icon, the story, and a facts strip.
class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key, required this.project, this.sidebar = false});

  final ProjectEntity project;

  /// Compact vertical layout for the left column on desktop.
  final bool sidebar;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    if (sidebar) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 3),
        children: [
          _TiltedIconWidget(project: project, size: context.space(factor: 11)),
          _StoryWidget(project: project, large: false),
          _FactsWidget(project: project, vertical: true),
        ],
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.04, end: 0);
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.space()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 3),
        children: [
          Row(
            spacing: context.space(factor: 2),
            children: [
              _TiltedIconWidget(
                project: project,
                size: context.space(factor: 10),
              ),
              Expanded(
                child: _StoryWidget(
                  project: project,
                  large: false,
                  showDescription: false,
                ),
              ),
            ],
          ),
          DSTextWidget(
            project.description,
            style: context.typography.bodyMedium,
            color: palette.neutral.grey8,
          ),
          _FactsWidget(project: project, grid: true),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.04, end: 0);
  }
}

/// Icon on a tilted gradient plate, so it pops without filling the column.
class _TiltedIconWidget extends StatelessWidget {
  const _TiltedIconWidget({required this.project, required this.size});

  final ProjectEntity project;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Padding(
      padding: EdgeInsets.only(
        left: context.space(),
        top: size * 0.15,
        bottom: context.space(factor: 2),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: size * 0.14,
            top: size * 0.14,
            child: Transform.rotate(
              angle: 0.14,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.225),
                  gradient: LinearGradient(
                    colors: [
                      palette.brand.primary.color,
                      palette.brand.tertiary.color,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: size * 0.14 + size * 0.7,
            top: -size * 0.1,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: palette.brand.primary.color.withAlpha(120),
                  width: 2,
                ),
              ),
            ),
          ),
          _IconWidget(project: project, size: size),
        ],
      ),
    );
  }
}

class _IconWidget extends StatelessWidget {
  const _IconWidget({required this.project, required this.size});

  final ProjectEntity project;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Hero(
      tag: 'project-image-${project.id}',
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.225),
          boxShadow: [
            BoxShadow(
              color: palette.brand.primary.color.withAlpha(90),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: DSNetworkImageWidget(url: project.image, fit: BoxFit.contain),
      ),
    ).animate().scale(
      begin: const Offset(0.8, 0.8),
      duration: 600.ms,
      curve: Curves.easeOutBack,
    );
  }
}

class _StoryWidget extends StatelessWidget {
  const _StoryWidget({
    required this.project,
    required this.large,
    this.showDescription = true,
  });

  final bool showDescription;

  final ProjectEntity project;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(),
      children: [
        Row(
          spacing: context.space(),
          children: [
            Container(
              width: context.space(factor: 3),
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    palette.brand.primary.color,
                    palette.brand.tertiary.color,
                  ],
                ),
              ),
            ),
            Flexible(
              child: DSTextWidget(
                project.category.toUpperCase(),
                style: context.typography.emphasizedLabelMedium,
                color: palette.brand.primary,
                maxLines: 1,
              ),
            ),
          ],
        ),
        DSTextWidget(
          project.title,
          style: large
              ? context.typography.emphasizedHeadlineLarge
              : context.typography.emphasizedHeadlineMedium,
          color: palette.neutral.grey10,
          maxLines: 2,
        ),
        if (showDescription)
          DSTextWidget(
            project.description,
            style: large
                ? context.typography.bodyLarge
                : context.typography.bodyMedium,
            color: palette.neutral.grey8,
            maxLines: 4,
          ),
      ],
    );
  }
}

/// Plain label/value columns split by hairlines, like an app-store info row.
class _FactsWidget extends StatelessWidget {
  const _FactsWidget({
    required this.project,
    this.vertical = false,
    this.grid = false,
  });

  final bool grid;

  final ProjectEntity project;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final palette = context.colorPalette;
    final markets = project.markets.map((m) => m.country).toSet().toList();
    final facts = [
      (l10n.projectFactStatus, project.status, project.statusIcon),
      (
        l10n.projectFactTeam,
        l10n.projectTeamSize('${project.teamSize}'),
        Icons.group_outlined,
      ),
      (l10n.projectFactRole, project.role, Icons.work_outline),
      (
        l10n.projectFactPeriod,
        project.formattedDateRange(context),
        Icons.calendar_month_outlined,
      ),
      if (markets.isNotEmpty)
        (l10n.projectFactMarkets, markets.join(' · '), Icons.public),
    ];

    if (vertical) {
      return Column(
        children: [
          for (final (index, fact) in facts.indexed)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: context.space()),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: palette.neutral.grey3.color),
                  bottom: index == facts.length - 1
                      ? BorderSide(color: palette.neutral.grey3.color)
                      : BorderSide.none,
                ),
              ),
              child: _FactWidget(
                label: fact.$1,
                value: fact.$2,
                icon: fact.$3,
                maxLines: 3,
              ),
            ),
        ],
      );
    }

    if (grid) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final gap = context.space(factor: 2);
          final columns = constraints.maxWidth >= 600 ? 3 : 2;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: context.space(factor: 1.5)),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: palette.neutral.grey3.color),
              ),
            ),
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final fact in facts)
                  SizedBox(
                    width: width,
                    child: _FactWidget(
                      label: fact.$1,
                      value: fact.$2,
                      icon: fact.$3,
                      maxLines: 2,
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }

    final children = <Widget>[];
    for (final (index, fact) in facts.indexed) {
      if (index > 0) {
        children.add(
          Container(
            width: 1,
            height: 44,
            margin: EdgeInsets.symmetric(horizontal: context.space(factor: 2)),
            color: palette.neutral.grey3.color,
          ),
        );
      }
      children.add(_FactWidget(label: fact.$1, value: fact.$2, icon: fact.$3));
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: context.space(factor: 1.5)),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: palette.neutral.grey3.color),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(child: Row(children: children)),
      ),
    );
  }
}

class _FactWidget extends StatelessWidget {
  const _FactWidget({
    required this.label,
    required this.value,
    required this.icon,
    this.maxLines = 1,
  });

  final int maxLines;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: context.space(factor: 0.5),
        children: [
          DSTextWidget(
            label.toUpperCase(),
            style: context.typography.emphasizedLabelSmall,
            color: palette.neutral.grey7,
            maxLines: 1,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: context.space(factor: 0.75),
            children: [
              Icon(icon, size: 18, color: palette.brand.primary.color),
              Flexible(
                child: DSTextWidget(
                  value,
                  style: context.typography.emphasizedTitleSmall,
                  color: palette.neutral.grey10,
                  maxLines: maxLines,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on ProjectEntity {
  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'active':
      case 'ongoing':
        return Icons.autorenew;
      case 'completed':
      case 'shipped':
        return Icons.check_circle_outline;
      case 'maintained':
        return Icons.verified_outlined;
      case 'paused':
        return Icons.pause_circle_outline;
      case 'archived':
      case 'deprecated':
        return Icons.archive_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
