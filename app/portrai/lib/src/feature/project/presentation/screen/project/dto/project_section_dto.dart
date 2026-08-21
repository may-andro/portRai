import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/widget/_widget.dart';
import 'package:tracking/tracking.dart';

abstract class ProjectSectionDTO {
  const ProjectSectionDTO({required this.project});

  final ProjectEntity project;

  Widget buildWidget(BuildContext context);
}

class IntroSectionDTO extends ProjectSectionDTO {
  IntroSectionDTO(ProjectEntity project) : super(project: project);

  @override
  Widget buildWidget(BuildContext context) {
    return IntroWidget(project: project);
  }
}

sealed class ScrollableProjectSectionDTO extends ProjectSectionDTO {
  const ScrollableProjectSectionDTO({
    required this.trackingId,
    required this.sectionKey,
    required super.project,
  });

  final String trackingId;
  final GlobalKey sectionKey;

  @override
  Widget buildWidget(BuildContext context) {
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

class OverviewSectionDTO extends ScrollableProjectSectionDTO {
  OverviewSectionDTO(ProjectEntity project)
    : super(
        trackingId: 'project_overview_section',
        sectionKey: GlobalKey(),
        project: project,
      );

  @override
  @protected
  String getTitle(BuildContext context) => 'Overview';

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return DSDetailSectionWidget(
      title: getTitle(context),
      child: DSTextWidget(
        project.longDescription,
        color: context.colorPalette.neutral.grey8,
        style: context.typography.bodyMedium,
      ),
    );
  }
}

class TechnologiesSectionDTO extends ScrollableProjectSectionDTO {
  TechnologiesSectionDTO(ProjectEntity project)
    : super(
        trackingId: 'project_technologies_section',
        sectionKey: GlobalKey(),
        project: project,
      );

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
        children: project.technologies
            .map((tech) => DSTagWidget(label: tech))
            .toList(),
      ),
    );
  }
}

class AchievementsSectionDTO extends ScrollableProjectSectionDTO {
  AchievementsSectionDTO(ProjectEntity project)
    : super(
        trackingId: 'project_achievements_section',
        sectionKey: GlobalKey(),
        project: project,
      );

  @override
  String getTitle(BuildContext context) => 'Achievements';

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return DSDetailSectionWidget(
      title: getTitle(context),
      child: DSBulletPointListWidget(bulletPoints: project.achievements),
    );
  }
}

class KeyFeaturesSectionDTO extends ScrollableProjectSectionDTO {
  KeyFeaturesSectionDTO(ProjectEntity project)
    : super(
        trackingId: 'project_key_features_section',
        sectionKey: GlobalKey(),
        project: project,
      );

  @override
  String getTitle(BuildContext context) => 'Key Features';

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return DSDetailSectionWidget(
      title: getTitle(context),
      child: DSBulletPointListWidget(bulletPoints: project.features),
    );
  }
}

class AvailabilitiesSectionDTO extends ScrollableProjectSectionDTO {
  AvailabilitiesSectionDTO(ProjectEntity project)
    : super(
        trackingId: 'project_available_on_section',
        sectionKey: GlobalKey(),
        project: project,
      );

  @override
  String getTitle(BuildContext context) => 'Available On';

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return DSDetailSectionWidget(
      title: getTitle(context),
      child: AvailabilitiesWidget(project: project),
    );
  }
}
