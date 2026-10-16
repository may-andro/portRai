import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/extension/project_date_range_extension.dart';
import 'package:portrai/src/widget/page_band_widget.dart';

/// Headline numbers (counted up when they scroll into view) and key facts.
class MetricsWidget extends StatelessWidget {
  const MetricsWidget({super.key, required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final metrics = project.metrics;
    return PageBandWidget(
      color: palette.surface.surfaceContainer.color,
      verticalFactor: 5,
      child: Column(
        spacing: context.space(factor: 4),
        children: [
          if (metrics.isNotEmpty) _MetricListWidget(metrics: metrics),
          if (metrics.isNotEmpty) Divider(color: palette.neutral.grey3.color),
          _FactListWidget(project: project),
        ],
      ),
    );
  }
}

class _MetricListWidget extends StatelessWidget {
  const _MetricListWidget({required this.metrics});

  final List<ProjectMetricEntity> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = context.space(factor: 3);
        final columnCount = context.isMobile ? 2 : metrics.length.clamp(1, 4);
        final metricWidth =
            (constraints.maxWidth - gap * (columnCount - 1)) / columnCount;
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: metricWidth.floorToDouble(),
                child: _MetricWidget(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class _FactListWidget extends StatelessWidget {
  const _FactListWidget({required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final facts = [
      (localizations.projectFactStatus, project.status, project.statusIcon),
      (
        localizations.projectFactTeam,
        localizations.projectTeamSize('${project.teamSize}'),
        Icons.group_outlined,
      ),
      (localizations.projectFactRole, project.role, Icons.work_outline),
      (
        localizations.projectFactPeriod,
        project.formattedDateRange(context),
        Icons.calendar_month_outlined,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = context.space(factor: 3);
        final columnCount = constraints.maxWidth >= 900 ? 4 : 2;
        final factWidth =
            (constraints.maxWidth - gap * (columnCount - 1)) / columnCount;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final fact in facts)
              SizedBox(
                width: factWidth.floorToDouble(),
                child: _FactWidget(
                  label: fact.$1,
                  value: fact.$2,
                  icon: fact.$3,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FactWidget extends StatelessWidget {
  const _FactWidget({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Row(
      spacing: context.space(factor: 1.5),
      children: [
        Container(
          padding: EdgeInsets.all(context.space(factor: 1.25)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.brand.primary.color.withAlpha(28),
          ),
          child: Icon(icon, size: 20, color: palette.brand.primary.color),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(factor: 0.25),
            children: [
              DSTextWidget(
                label.toUpperCase(),
                style: context.typography.emphasizedLabelSmall,
                color: palette.neutral.grey7,
                maxLines: 1,
              ),
              DSTextWidget(
                value,
                style: context.typography.emphasizedTitleSmall,
                color: palette.neutral.grey10,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricWidget extends StatelessWidget {
  const _MetricWidget({required this.metric});

  final ProjectMetricEntity metric;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Column(
      spacing: context.space(factor: 0.5),
      children: [
        FittedBox(
          child: CountUpWidget(
            value: metric.value,
            style: context.typography.emphasizedHeadlineMedium,
            color: palette.brand.primary,
          ),
        ),
        DSTextWidget(
          metric.label.toUpperCase(),
          style: context.typography.emphasizedLabelMedium,
          color: palette.neutral.grey7,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ],
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
