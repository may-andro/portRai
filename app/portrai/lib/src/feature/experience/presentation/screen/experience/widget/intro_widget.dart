import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key, required this.experience});

  final ExperienceEntity experience;

  @override
  Widget build(BuildContext context) {
    if (context.isTablet) {
      return Row(
        spacing: context.space(factor: 3),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _ImageWidget(experience: experience)),
          SizedBox(width: context.space(factor: 2)),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(),
              children: [
                _PositionWidget(experience: experience),
                _DescriptionWidget(experience: experience),
                const DSVerticalSpacerWidget(0.25),
                _InfoChipsWidget(experience: experience),
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
        _ImageWidget(experience: experience),
        const DSVerticalSpacerWidget(1),
        _PositionWidget(experience: experience),
        _DescriptionWidget(experience: experience),
        const DSVerticalSpacerWidget(0.25),
        _InfoChipsWidget(experience: experience),
      ],
    );
  }
}

class _PositionWidget extends StatelessWidget {
  const _PositionWidget({required this.experience});

  final ExperienceEntity experience;

  @override
  Widget build(BuildContext context) {
    return DSTextWidget(
      experience.position.toUpperCase(),
      color: context.colorPalette.neutral.grey8,
      style: context.typography.emphasizedBodyLarge,
    );
  }
}

class _DescriptionWidget extends StatelessWidget {
  const _DescriptionWidget({required this.experience});

  final ExperienceEntity experience;

  @override
  Widget build(BuildContext context) {
    return DSTextWidget(
      experience.description,
      style: context.typography.bodyLarge,
      color: context.colorPalette.neutral.grey10,
      isItalic: true,
    );
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget({required this.experience});

  final ExperienceEntity experience;

  @override
  Widget build(BuildContext context) {
    final url = experience.url;
    return Hero(
      tag: 'experience-image-${experience.id}',
      child: InkWell(
        onTap: url != null
            ? () {
                context.bloc.add(
                  OpenExternalUrlEvent(
                    url: url,
                    label: 'Experience Company Website',
                  ),
                );
              }
            : null,
        child: DSNetworkImageWidget(
          url: experience.companyLogo,
          autoSizeImage: true,
          fit: BoxFit.contain,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
          color: context.colorPalette.surface.inverseSurface,
        ),
      ),
    );
  }
}

class _InfoChipsWidget extends StatelessWidget {
  const _InfoChipsWidget({required this.experience});

  final ExperienceEntity experience;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.space(factor: context.isDesktop ? 1.0 : 1.5),
      runSpacing: context.space(factor: context.isDesktop ? 1.0 : 1.5),
      children: [
        DSInfoChipWidget(
          label: experience.employmentType,
          icon: Icons.work_outline,
        ),
        DSInfoChipWidget(
          label: experience.location,
          icon: Icons.location_on_outlined,
        ),
        DSInfoChipWidget(
          label: experience.formattedExperienceDateRange,
          icon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }
}
