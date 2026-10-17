part of 'professional_summary_widget.dart';

class _EyebrowWidget extends StatelessWidget {
  const _EyebrowWidget({
    required this.profile,
    required this.hasHorizontalPadding,
    required this.isVisible,
  });

  final ProfileEntity profile;
  final bool hasHorizontalPadding;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: hasHorizontalPadding
          ? context.horizontalScreenPadding
          : EdgeInsets.zero,
      child:
          Row(
                mainAxisSize: MainAxisSize.min,
                spacing: context.space(factor: 1.5),
                children: [
                  DSHoverableContainerWidget(
                    builder: (context, isHovering) => AnimatedContainer(
                      duration: 250.ms,
                      curve: Curves.easeOut,
                      width: context.space(factor: isHovering ? 8 : 4),
                      height: 2,
                      color: context.colorPalette.brand.primary.color,
                    ),
                  ),
                  Flexible(
                    child: DSTextWidget(
                      '${profile.fullName.toUpperCase()}  ·  '
                      '${profile.subtitle}',
                      style: context.typography.emphasizedLabelMedium,
                      color: context.colorPalette.brand.primary,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
              .animate(target: isVisible ? 1 : 0)
              .slideX(begin: -0.1, duration: 300.ms, curve: Curves.easeOut)
              .fadeIn(duration: 300.ms),
    );
  }
}

class _Fact {
  const _Fact({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _FactsWidget extends StatelessWidget {
  const _FactsWidget({
    required this.facts,
    required this.hasHorizontalPadding,
    required this.isVisible,
  });

  final List<_Fact> facts;
  final bool hasHorizontalPadding;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    if (facts.isEmpty) return const SizedBox.shrink();
    final accent = context.colorPalette.brand.primary.color;

    return Padding(
      padding: hasHorizontalPadding
          ? context.horizontalScreenPadding
          : EdgeInsets.zero,
      child:
          Wrap(
                spacing: context.space(),
                runSpacing: context.space(),
                children: [
                  for (final fact in facts)
                    DSHoverableContainerWidget(
                      builder: (context, isHovering) => AnimatedContainer(
                        duration: 220.ms,
                        curve: Curves.easeOut,
                        transform: Matrix4.translationValues(
                          0,
                          isHovering ? -3 : 0,
                          0,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.space(factor: 1.5),
                          vertical: context.space(),
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: accent.withAlpha(isHovering ? 90 : 0),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          color: accent.withAlpha(isHovering ? 55 : 30),
                          borderRadius: BorderRadius.circular(
                            context.dimen.radiusLevel3.value,
                          ),
                          border: Border.all(color: accent.withAlpha(90)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: context.space(),
                          children: [
                            Icon(fact.icon, size: 16, color: accent),
                            Flexible(
                              child: DSTextWidget(
                                fact.label,
                                style: context.typography.emphasizedLabelMedium,
                                color: context.colorPalette.surface.onSurface,
                                maxLines: 1,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
              .animate(target: isVisible ? 1 : 0)
              .slideY(
                begin: 0.4,
                duration: 300.ms,
                delay: 150.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 300.ms, delay: 150.ms),
    );
  }
}
