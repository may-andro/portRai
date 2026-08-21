import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/widget/intro_widget.dart';
import 'package:tracking/tracking.dart';

abstract class SectionWidget extends StatelessWidget {
  const SectionWidget({super.key, required this.experience});

  final ExperienceEntity experience;
}

class IntroSectionWidget extends SectionWidget {
  const IntroSectionWidget({super.key, required super.experience});

  @override
  Widget build(BuildContext context) {
    return IntroWidget(experience: experience);
  }
}

sealed class ScrollableSectionWidget extends SectionWidget {
  ScrollableSectionWidget({
    super.key,
    required this.trackingId,
    required super.experience,
  }) : sectionKey = GlobalKey();

  final String trackingId;
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    return TrackingImpressionDetectorWidget(
      impressionId: trackingId,
      onImpression: () => context.bloc.add(SectionVisibleEvent(trackingId)),
      child: KeyedSubtree(key: sectionKey, child: buildContent(context)),
    );
  }

  String getTitle(BuildContext context);

  @protected
  Widget buildContent(BuildContext context);
}

class OverviewSectionWidget extends ScrollableSectionWidget {
  OverviewSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_overview_section');

  @override
  String getTitle(BuildContext context) => 'Overview';

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return DSDetailSectionWidget(
      title: getTitle(context),
      child: DSTextWidget(
        experience.longDescription,
        color: context.colorPalette.neutral.grey8,
        style: context.typography.bodyMedium,
      ),
    );
  }
}

class TechnologiesSectionWidget extends ScrollableSectionWidget {
  TechnologiesSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_technologies_section');

  @override
  String getTitle(BuildContext context) => 'Technologies';

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return DSDetailSectionWidget(
      title: getTitle(context),
      child: Wrap(
        spacing: context.space(),
        runSpacing: context.space(),
        children: experience.technologies
            .map((tech) => DSTagWidget(label: tech))
            .toList(),
      ),
    );
  }
}

class AchievementsSectionWidget extends ScrollableSectionWidget {
  AchievementsSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_achievements_section');

  @override
  String getTitle(BuildContext context) => 'Achievements';

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return DSDetailSectionWidget(
      title: getTitle(context),
      child: DSBulletPointListWidget(bulletPoints: experience.achievements),
    );
  }
}

class ResponsibilitiesSectionWidget extends ScrollableSectionWidget {
  ResponsibilitiesSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_responsibilities_section');

  @override
  String getTitle(BuildContext context) => 'Responsibilities';

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return DSDetailSectionWidget(
      title: getTitle(context),
      child: DSBulletPointListWidget(bulletPoints: experience.responsibilities),
    );
  }
}
