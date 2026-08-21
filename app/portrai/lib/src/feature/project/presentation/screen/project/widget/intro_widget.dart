import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key, required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    if (context.isTablet) {
      return Row(
        spacing: context.space(factor: 3),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _ImageWidget(project: project)),
          SizedBox(width: context.space(factor: 2)),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(),
              children: [
                _CategoryWidget(project: project),
                _DescriptionWidget(project: project),
                const DSVerticalSpacerWidget(0.25),
                _InfoChipsWidget(project: project),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(),
      children: [
        _ImageWidget(project: project),
        const DSVerticalSpacerWidget(1),
        _CategoryWidget(project: project),
        _DescriptionWidget(project: project),
        const DSVerticalSpacerWidget(0.25),
        _InfoChipsWidget(project: project),
      ],
    );
  }
}

class _CategoryWidget extends StatelessWidget {
  const _CategoryWidget({required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    return DSTextWidget(
      project.category.toUpperCase(),
      color: context.colorPalette.neutral.grey8,
      style: context.typography.emphasizedBodyLarge,
    );
  }
}

class _DescriptionWidget extends StatelessWidget {
  const _DescriptionWidget({required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    return DSTextWidget(
      project.description,
      style: context.typography.bodyLarge,
      color: context.colorPalette.neutral.grey10,
      isItalic: true,
    );
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget({required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'project-image-${project.title}',
      child: DSNetworkImageWidget(
        url: project.image,
        autoSizeImage: true,
        fit: BoxFit.contain,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
        color: context.colorPalette.surface.inverseSurface,
      ),
    );
  }
}

class _InfoChipsWidget extends StatelessWidget {
  const _InfoChipsWidget({required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.space(factor: context.isDesktop ? 1.0 : 1.5),
      runSpacing: context.space(factor: context.isDesktop ? 1.0 : 1.5),
      children: [
        DSInfoChipWidget(label: project.status, icon: project.statusIcon),
        DSInfoChipWidget(
          label: '${project.teamSize} people',
          icon: Icons.group,
        ),
        DSInfoChipWidget(label: project.role, icon: Icons.work),
        DSInfoChipWidget(
          label: project.formattedDateRange,
          icon: Icons.calendar_month,
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
