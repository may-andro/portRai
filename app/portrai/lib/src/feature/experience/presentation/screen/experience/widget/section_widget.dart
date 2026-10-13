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

  IconData get icon;

  @protected
  Widget buildContent(BuildContext context);
}

class OverviewSectionWidget extends ScrollableSectionWidget {
  OverviewSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_overview_section');

  @override
  String getTitle(BuildContext context) => 'Overview';

  @override
  IconData get icon => Icons.auto_awesome_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return _SectionPanelWidget(
      title: getTitle(context),
      icon: icon,
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
  IconData get icon => Icons.memory_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return _SectionPanelWidget(
      title: getTitle(context),
      icon: icon,
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
  IconData get icon => Icons.emoji_events_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return _SectionPanelWidget(
      title: getTitle(context),
      icon: icon,
      child: _AchievementListWidget(items: experience.achievements),
    );
  }
}

class ResponsibilitiesSectionWidget extends ScrollableSectionWidget {
  ResponsibilitiesSectionWidget({super.key, required super.experience})
    : super(trackingId: 'experience_responsibilities_section');

  @override
  String getTitle(BuildContext context) => 'Responsibilities';

  @override
  IconData get icon => Icons.task_alt_rounded;

  @override
  @protected
  Widget buildContent(BuildContext context) {
    return _SectionPanelWidget(
      title: getTitle(context),
      icon: icon,
      child: _ResponsibilityListWidget(items: experience.responsibilities),
    );
  }
}

class _SectionPanelWidget extends StatefulWidget {
  const _SectionPanelWidget({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  State<_SectionPanelWidget> createState() => _SectionPanelWidgetState();
}

class _SectionPanelWidgetState extends State<_SectionPanelWidget> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: 250.ms,
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: palette.surface.surfaceContainer.color,
          border: Border.all(
            color: _hover ? accent.withAlpha(140) : palette.neutral.grey3.color,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withAlpha(_hover ? 50 : 12),
              blurRadius: _hover ? 28 : 10,
              offset: Offset(0, _hover ? 12 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: 300.ms,
                height: 4,
                margin: EdgeInsets.only(
                  right: _hover ? 0 : context.space(factor: 20),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, palette.brand.tertiary.color],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(context.space(factor: 3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: context.space(factor: 2),
                  children: [
                    Row(
                      spacing: context.space(factor: 1.5),
                      children: [
                        Container(
                          padding: EdgeInsets.all(context.space()),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withAlpha(30),
                          ),
                          child: Icon(widget.icon, size: 20, color: accent),
                        ),
                        Expanded(
                          child: DSTextWidget(
                            widget.title,
                            style: context.typography.emphasizedTitleLarge,
                            color: palette.neutral.grey9,
                          ),
                        ),
                      ],
                    ),
                    widget.child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
  }
}

/// Compact rows with a gradient trophy badge: achievements are "wins".
class _AchievementListWidget extends StatelessWidget {
  const _AchievementListWidget({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.tertiary.color;
    return Column(
      spacing: context.space(factor: 1.25),
      children: [
        for (final (index, item) in items.indexed)
          Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: context.space(factor: 1.25),
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accent, palette.brand.primary.color],
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: DSTextWidget(
                      item,
                      style: context.typography.emphasizedBodyMedium,
                      color: palette.neutral.grey10,
                    ),
                  ),
                ],
              )
              .animate(delay: (index * 100).ms)
              .fadeIn()
              .slideX(begin: 0.05, end: 0),
      ],
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
