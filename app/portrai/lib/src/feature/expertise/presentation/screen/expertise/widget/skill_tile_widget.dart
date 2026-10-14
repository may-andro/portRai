part of 'content_widget.dart';

/// One skill laid out as its own full-width section: index, name and
/// description, then the proficiency meter with years and last-used details.
class _SkillSectionWidget extends StatefulWidget {
  const _SkillSectionWidget({required this.skill, required this.index});

  final SkillEntity skill;
  final int index;

  @override
  State<_SkillSectionWidget> createState() => _SkillSectionWidgetState();
}

class _SkillSectionWidgetState extends State<_SkillSectionWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final skill = widget.skill;
    final accent = [
      palette.brand.primary,
      palette.brand.tertiary,
      palette.brand.secondary,
    ][widget.index % 3].color;
    final isWide = !context.isMobile;
    final levelLabel = switch (skill.level) {
      'expert' => localizations.expertiseLevelExpert,
      'advanced' => localizations.expertiseLevelAdvanced,
      'intermediate' => localizations.expertiseLevelIntermediate,
      'familiar' => localizations.expertiseLevelFamiliar,
      _ => null,
    };
    final progress = switch (skill.level) {
      'expert' => 1.0,
      'advanced' => 0.75,
      'intermediate' => 0.5,
      'familiar' => 0.25,
      _ => null,
    };
    final details = [
      if (skill.years != null)
        localizations.expertiseYearsExperience(skill.years!),
      if (skill.lastUsed != null)
        localizations.expertiseLastUsed(skill.lastUsed!.toString()),
    ].join(' · ');

    final index = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: isWide ? 40 : 28,
        fontWeight: FontWeight.w700,
        color: accent.withAlpha(_hovering ? 255 : 110),
      ),
      child: Text((widget.index + 1).toString().padLeft(2, '0')),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 0.5),
      children: [
        DSTextWidget(
          skill.name,
          style: isWide
              ? context.typography.emphasizedHeadlineSmall
              : context.typography.emphasizedTitleLarge,
          color: _hovering
              ? DSColor(accent.toARGB32())
              : palette.neutral.grey10,
        ),
        if (skill.description != null)
          DSTextWidget(
            skill.description!,
            style: context.typography.bodyMedium,
            color: palette.neutral.grey8,
          ),
      ],
    );

    final meter = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.space(factor: 0.75),
      children: [
        if (levelLabel != null)
          DSTextWidget(
            levelLabel.toUpperCase(),
            style: context.typography.emphasizedLabelMedium,
            color: palette.neutral.grey7,
          ),
        if (progress != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 6,
              color: palette.neutral.grey9.color.withAlpha(25),
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent.withAlpha(120), accent],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        if (details.isNotEmpty)
          DSTextWidget(
            details,
            style: context.typography.labelMedium,
            color: palette.neutral.grey7,
          ),
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: context.space(factor: 3)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _hovering
                  ? accent
                  : palette.neutral.grey9.color.withAlpha(30),
              width: _hovering ? 2 : 1,
            ),
          ),
        ),
        child: isWide
            ? Row(
                spacing: context.space(factor: 4),
                children: [
                  SizedBox(width: 72, child: index),
                  Expanded(flex: 3, child: text),
                  Expanded(flex: 2, child: meter),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: context.space(factor: 1.5),
                children: [index, text, meter],
              ),
      ),
    );
  }
}
