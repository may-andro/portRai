import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/experience_screen.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/widget/intro_widget.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/widget/key_facts_widget.dart';
import 'package:portrai/src/widget/page_band_widget.dart';
import 'package:portrai/src/widget/page_image_backdrop_widget.dart';
import 'package:portrai/src/widget/page_technology_chip_widget.dart';
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

class KeyFactsSectionWidget extends SectionWidget {
  const KeyFactsSectionWidget({super.key, required super.experience});

  @override
  Widget build(BuildContext context) {
    return KeyFactsWidget(experience: experience);
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

  IconData get icon;

  @protected
  Widget buildContent(BuildContext context);
}

class OverviewSectionWidget extends ScrollableSectionWidget {
  OverviewSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_overview_section');

  @override
  String getTitle(BuildContext context) =>
      context.localizations.experienceSectionOverview;

  @override
  IconData get icon => Icons.auto_awesome_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return PageSectionBandWidget(
      title: getTitle(context),
      color: context.colorPalette.surface.surface.color,
      background: _LogoBackdropWidget(imageUrl: experience.companyLogo),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: DSTextWidget(
          experience.longDescription,
          color: context.colorPalette.neutral.grey8,
          style: context.typography.bodyLarge,
        ),
      ),
    );
  }
}

class TechnologiesSectionWidget extends ScrollableSectionWidget {
  TechnologiesSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_technologies_section');

  @override
  String getTitle(BuildContext context) =>
      context.localizations.experienceSectionTechnologies;

  @override
  IconData get icon => Icons.memory_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    final washColor = context.colorPalette.surface.surfaceContainer.color;
    // Image shows through on the right; the chips sit on the solid left side.
    return PageSectionBandWidget(
      title: getTitle(context),
      color: washColor,
      background: PageImageBackdropWidget(
        asset: 'assets/service/technology_background.jpg',
        washColor: washColor,
        imageAlignment: Alignment.centerRight,
        washOpacityAtBegin: 0.97,
        washOpacityAtEnd: 0.75,
      ),
      child: Wrap(
        spacing: context.space(factor: 1.5),
        runSpacing: context.space(factor: 1.5),
        children: [
          for (final (index, technology) in experience.technologies.indexed)
            PageTechnologyChipWidget(label: technology)
                .animate(delay: (index * 40).ms)
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
        ],
      ),
    );
  }
}

class AchievementsSectionWidget extends ScrollableSectionWidget {
  AchievementsSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_achievements_section');

  @override
  String getTitle(BuildContext context) =>
      context.localizations.experienceSectionAchievements;

  @override
  IconData get icon => Icons.emoji_events_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return PageSectionBandWidget(
      title: getTitle(context),
      color: context.colorPalette.surface.surfaceContainer.color,
      child: _AchievementGridWidget(items: experience.achievements),
    );
  }
}

class ResponsibilitiesSectionWidget extends ScrollableSectionWidget {
  ResponsibilitiesSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_responsibilities_section');

  @override
  String getTitle(BuildContext context) =>
      context.localizations.experienceSectionResponsibilities;

  @override
  IconData get icon => Icons.task_alt_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return PageSectionBandWidget(
      title: getTitle(context),
      color: context.colorPalette.surface.surface.color,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: _ResponsibilityListWidget(items: experience.responsibilities),
      ),
    );
  }
}

class LocationSectionWidget extends ScrollableSectionWidget {
  LocationSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_location_section');

  @override
  String getTitle(BuildContext context) =>
      context.localizations.experienceSectionLocation;

  @override
  IconData get icon => Icons.place_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return PageSectionBandWidget(
      title: getTitle(context),
      color: context.colorPalette.surface.surface.color,
      child: _LocationMapWidget(experience: experience),
    );
  }
}

/// Links to the roles that start right before and right after this one.
class AdjacentExperiencesSectionWidget extends SectionWidget {
  const AdjacentExperiencesSectionWidget({
    super.key,
    required super.experience,
    this.newerExperience,
    this.olderExperience,
  });

  final ExperienceEntity? newerExperience;
  final ExperienceEntity? olderExperience;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    const base = Color(0xFF0E1726);
    final localizations = context.localizations;
    final cards = [
      if (olderExperience case final ExperienceEntity older)
        _AdjacentCardWidget(
          label: localizations.experienceOlderRole,
          adjacentExperience: older,
          icon: Icons.arrow_back_rounded,
        ),
      if (newerExperience case final ExperienceEntity newer)
        _AdjacentCardWidget(
          label: localizations.experienceNewerRole,
          adjacentExperience: newer,
          icon: Icons.arrow_forward_rounded,
        ),
    ];
    return PageBandWidget(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(base, palette.brand.primary.color, 0.25)!,
          Color.lerp(base, palette.brand.tertiary.color, 0.2)!,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 3),
        children: [
          PageEyebrowWidget(
            localizations.experienceKeepExploring,
            onDark: true,
          ),
          if (context.isDesktop)
            Row(
              spacing: context.space(factor: 3),
              children: [for (final card in cards) Expanded(child: card)],
            )
          else
            Column(spacing: context.space(factor: 2), children: cards),
        ],
      ),
    );
  }
}

class _AdjacentCardWidget extends StatelessWidget {
  const _AdjacentCardWidget({
    required this.label,
    required this.adjacentExperience,
    required this.icon,
  });

  final String label;
  final ExperienceEntity adjacentExperience;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final logoSize = context.space(factor: 7);
    return HoverLiftWidget(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            context.bloc.add(
              AdjacentExperienceClickEvent(adjacentExperience.id),
            );
            ExperienceScreen.navigate(context, id: adjacentExperience.id);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.space(factor: 2.5)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                context.dimen.radiusLevel3.value,
              ),
              color: Colors.white.withAlpha(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              spacing: context.space(factor: 2),
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  padding: EdgeInsets.all(logoSize * 0.14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(logoSize * 0.24),
                  ),
                  child: DSNetworkImageWidget(
                    url: adjacentExperience.companyLogo,
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: context.space(factor: 0.5),
                    children: [
                      DSTextWidget(
                        label.toUpperCase(),
                        style: context.typography.emphasizedLabelMedium,
                        color: const DSColor(0xFF9CC9FF),
                      ),
                      DSTextWidget(
                        adjacentExperience.position,
                        style: context.typography.emphasizedTitleMedium,
                        color: pageOnDarkColor,
                      ),
                      DSTextWidget(
                        adjacentExperience.company,
                        style: context.typography.bodyMedium,
                        color: const DSColor(0xD9FFFFFF),
                      ),
                    ],
                  ),
                ),
                Icon(icon, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Static map of the company location; page scrolling is never captured.
class _LocationMapWidget extends StatelessWidget {
  const _LocationMapWidget({required this.experience});

  final ExperienceEntity experience;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final position = LatLng(experience.latitude!, experience.longitude!);
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: context.isDesktop ? 380 : 260,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: position,
                    zoom: 11,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('experience_location'),
                      position: position,
                    ),
                  },
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
            Positioned(
              left: context.space(factor: 2),
              bottom: context.space(factor: 2),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(factor: 2),
                  vertical: context.space(factor: 1.25),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    context.dimen.radiusLevel2.value,
                  ),
                  color: palette.surface.surface.color,
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 16),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: context.space(),
                  children: [
                    Icon(
                      Icons.place_rounded,
                      size: 18,
                      color: palette.brand.primary.color,
                    ),
                    DSTextWidget(
                      experience.location,
                      style: context.typography.emphasizedBodyMedium,
                      color: palette.neutral.grey10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Oversized, faded company logo with pulsing rings and an orbiting dot.
class _LogoBackdropWidget extends StatelessWidget {
  const _LogoBackdropWidget({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    final secondary = palette.brand.tertiary.color;
    final size = context.isDesktop ? 520.0 : 320.0;
    return DSOffscreenPauseWidget(
      child: IgnorePointer(
        child: ClipRect(
          child: Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: Offset(size * 0.3, 0),
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final (ringIndex, scale) in [1.0, 0.78, 0.56].indexed)
                      Container(
                            width: size * scale,
                            height: size * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: accent.withAlpha(36)),
                            ),
                          )
                          .animate(
                            delay: (ringIndex * 600).ms,
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .scale(
                            begin: const Offset(0.97, 0.97),
                            end: const Offset(1.03, 1.03),
                            duration: 3.seconds,
                            curve: Curves.easeInOut,
                          ),
                    Container(
                      width: size * 0.56,
                      height: size * 0.56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [accent.withAlpha(34), accent.withAlpha(0)],
                        ),
                      ),
                    ),
                    SizedBox.expand(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: secondary,
                                boxShadow: [
                                  BoxShadow(
                                    color: secondary.withAlpha(140),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(duration: 20.seconds),
                    Opacity(
                          opacity: 0.12,
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Colors.grey,
                              BlendMode.saturation,
                            ),
                            child: DSNetworkImageWidget(
                              url: imageUrl,
                              width: size * 0.42,
                              height: size * 0.42,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .moveY(
                          begin: -10,
                          end: 10,
                          duration: 4.seconds,
                          curve: Curves.easeInOut,
                        )
                        .rotate(begin: -0.01, end: 0.01, duration: 6.seconds),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wins laid out as cards, each with a gradient trophy badge.
class _AchievementGridWidget extends StatelessWidget {
  const _AchievementGridWidget({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final gap = context.space(factor: 2);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        final cardWidth =
            (constraints.maxWidth - gap * (columnCount - 1)) / columnCount;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (index, item) in items.indexed)
              SizedBox(
                    width: cardWidth,
                    child: HoverLiftWidget(
                      child: _AchievementCardWidget(item: item),
                    ),
                  )
                  .animate(delay: (index * 100).ms)
                  .fadeIn()
                  .slideY(begin: 0.08, end: 0),
          ],
        );
      },
    );
  }
}

class _AchievementCardWidget extends StatelessWidget {
  const _AchievementCardWidget({required this.item});

  final String item;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Container(
      padding: EdgeInsets.all(context.space(factor: 2.5)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
        color: palette.surface.surface.color,
        border: Border.all(color: palette.neutral.grey3.color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 1.5),
        children: [
          Container(
            padding: EdgeInsets.all(context.space(factor: 1.25)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  palette.brand.tertiary.color,
                  palette.brand.primary.color,
                ],
              ),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          DSTextWidget(
            item,
            style: context.typography.emphasizedBodyMedium,
            color: palette.neutral.grey10,
          ),
        ],
      ),
    );
  }
}

/// Numbered steps along a vertical line: responsibilities are ongoing duties.
class _ResponsibilityListWidget extends StatelessWidget {
  const _ResponsibilityListWidget({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    return Column(
      children: [
        for (final (index, item) in items.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: context.space(factor: 1.5),
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 1.5),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (index != items.length - 1)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            color: accent.withAlpha(60),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 3,
                      bottom: context.space(factor: 2),
                    ),
                    child: DSTextWidget(
                      item,
                      style: context.typography.bodyMedium,
                      color: palette.neutral.grey8,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
