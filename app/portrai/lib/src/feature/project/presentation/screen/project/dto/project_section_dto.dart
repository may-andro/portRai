import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/widget/_widget.dart';
import 'package:portrai/src/widget/page_band_widget.dart';
import 'package:portrai/src/widget/page_image_backdrop_widget.dart';
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

  IconData get icon;

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
  String getTitle(BuildContext context) =>
      context.localizations.projectOverview;

  @override
  IconData get icon => Icons.auto_awesome_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return PageSectionBandWidget(
      title: getTitle(context),
      color: context.colorPalette.surface.surface.color,
      background: ProjectImageBackdropWidget(imageUrl: project.image),
      child: ProjectOverviewWidget(project: project),
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
  String getTitle(BuildContext context) =>
      context.localizations.projectTechnologies;

  @override
  IconData get icon => Icons.memory_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    final washColor = context.colorPalette.surface.surface.color;
    // Mirrored image, washed from top to bottom, so it reads differently
    // from the experience page's side-lit version.
    return PageSectionBandWidget(
      title: getTitle(context),
      color: washColor,
      background: PageImageBackdropWidget(
        asset: 'assets/service/technology_background.jpg',
        washColor: washColor,
        isFlipped: true,
        imageAlignment: Alignment.bottomCenter,
        washBegin: Alignment.topCenter,
        washEnd: Alignment.bottomCenter,
        washOpacityAtBegin: 0.96,
        washOpacityAtEnd: 0.82,
      ),
      child: ProjectTechMarqueeWidget(items: project.technologies),
    );
  }
}

class MarketsSectionDTO extends ScrollableProjectSectionDTO {
  MarketsSectionDTO(ProjectEntity project)
    : super(
        trackingId: 'project_markets_section',
        sectionKey: GlobalKey(),
        project: project,
      );

  @override
  String getTitle(BuildContext context) =>
      context.localizations.projectFactMarkets;

  @override
  IconData get icon => Icons.public_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return PageSectionBandWidget(
      title: getTitle(context),
      color: context.colorPalette.surface.surface.color,
      child: ProjectMarketsWidget(markets: project.markets),
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
  String getTitle(BuildContext context) =>
      context.localizations.projectAchievements;

  @override
  IconData get icon => Icons.emoji_events_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return PageSectionBandWidget(
      title: getTitle(context),
      color: context.colorPalette.surface.surfaceContainer.color,
      child: ProjectAchievementStripWidget(items: project.achievements),
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
  String getTitle(BuildContext context) =>
      context.localizations.projectKeyFeatures;

  @override
  IconData get icon => Icons.bolt_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return PageSectionBandWidget(
      title: getTitle(context),
      color: context.colorPalette.surface.surfaceContainer.color,
      child: ProjectFeatureBentoWidget(items: project.features),
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
  String getTitle(BuildContext context) =>
      context.localizations.projectAvailableOn;

  @override
  IconData get icon => Icons.rocket_launch_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    final palette = context.colorPalette;
    const base = Color(0xFF0E1726);
    return PageSectionBandWidget(
      title: getTitle(context),
      onDark: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(base, palette.brand.primary.color, 0.3)!,
          Color.lerp(base, palette.brand.tertiary.color, 0.25)!,
        ],
      ),
      child: AvailabilitiesWidget(project: project),
    );
  }
}
