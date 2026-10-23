part of 'expertise_orbit_widget.dart';

/// One expertise as a round node, lifted and lit by [accent] when selected.
/// It fills [size] scaled by [selectedScale] when selected and by
/// [restingScale] otherwise.
class _OrbitNodeWidget extends StatelessWidget {
  const _OrbitNodeWidget({
    required this.expertise,
    required this.isSelected,
    required this.size,
    required this.accent,
    this.selectedScale = 1.2,
    this.restingScale = 1,
  });

  final ExpertiseEntity expertise;
  final bool isSelected;
  final double size;
  final Color accent;
  final double selectedScale;
  final double restingScale;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final background = palette.surface.inverseSurface.color;
    final foreground = palette.surface.onInverseSurface.color;

    return AnimatedSlide(
      offset: isSelected ? const Offset(0, -0.08) : Offset.zero,
      duration: 220.ms,
      curve: Curves.easeOutBack,
      child: AnimatedScale(
        scale: isSelected ? selectedScale : restingScale,
        duration: 220.ms,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: 220.ms,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? accent
                : Color.alphaBlend(foreground.withAlpha(18), background),
            border: Border.all(
              color: isSelected ? accent : foreground.withAlpha(70),
              width: 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: accent.withAlpha(120),
                  blurRadius: 22,
                  offset: Offset(0, size * 0.12),
                )
              else
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 8,
                  offset: Offset(0, size * 0.05),
                ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(size * (isSelected ? 0.1 : 0.14)),
            child: DSNetworkImageWidget(
              url: expertise.image,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(size),
            ),
          ),
        ),
      ),
    );
  }
}

/// The selected expertise's name and skill count, with a button that opens
/// it so touch screens don't rely on tapping the selected node again.
class _OrbitSummaryWidget extends StatelessWidget {
  const _OrbitSummaryWidget({
    super.key,
    required this.expertise,
    required this.accent,
    required this.onOpen,
  });

  final ExpertiseEntity expertise;
  final Color accent;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final skillsLabel =
        '${expertise.skills.length} '
        '${context.localizations.expertiseStatSkills}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(),
      children: [
        Flexible(
          child: DSTextWidget(
            expertise.title,
            style: context.typography.emphasizedHeadlineSmall,
            color: context.colorPalette.surface.onInverseSurface,
            textAlign: TextAlign.center,
            maxLines: 3,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.space(),
            vertical: context.space() / 3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: accent.withAlpha(36),
            border: Border.all(color: accent.withAlpha(140)),
          ),
          child: DSTextWidget(
            skillsLabel,
            style: context.typography.labelSmall,
            color: _dsColor(accent),
          ),
        ),
        // Shrinks rather than overflows in the middle of a small orbit.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: DSButtonWidget(
            label: context.localizations.expertiseViewDetails,
            onPressed: onOpen,
            size: DSButtonSize.extraSmall,
            icon: Icons.arrow_forward_rounded,
            iconDirection: DSButtonIconDirection.right,
            isExpanded: false,
          ),
        ),
      ],
    );
  }
}
