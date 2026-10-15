part of 'content_widget.dart';

class _SectionWidget extends StatefulWidget {
  const _SectionWidget({
    required this.title,
    required this.icon,
    required this.child,
    this.isAlternate = false,
    this.backgroundAsset,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool isAlternate;
  final String? backgroundAsset;

  @override
  State<_SectionWidget> createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<_SectionWidget> {
  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 1.5),
      children: [_buildTitle(context), widget.child],
    );

    final backgroundColor = widget.isAlternate
        ? Color.alphaBlend(accent.withAlpha(30), palette.background.color)
        : palette.background.color;
    final band = Container(
      width: double.infinity,
      color: backgroundColor,
      child: ClipRect(
        child: Stack(
          children: [
            if (widget.backgroundAsset case final backgroundAsset?)
              Positioned.fill(
                child: _SectionArtworkWidget(
                  assetPath: backgroundAsset,
                  accent: accent,
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
                vertical: context.space(factor: 6),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: content,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return _RevealWidget(child: band);
  }

  Widget _buildTitle(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    final typography = context.typography;
    final badge = Container(
      padding: EdgeInsets.all(context.space()),
      decoration: BoxDecoration(
        color: accent.withAlpha(36),
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel1.value),
      ),
      child: Icon(widget.icon, size: 26, color: accent),
    );

    return Row(
      spacing: context.space(factor: 1.25),
      children: [
        badge,
        DSTextWidget(
          widget.title,
          style: context.isMobile
              ? typography.emphasizedHeadlineSmall
              : typography.emphasizedHeadlineMedium,
          color: palette.neutral.grey10,
        ),
      ],
    );
  }
}

class _SectionArtworkWidget extends StatelessWidget {
  const _SectionArtworkWidget({required this.assetPath, required this.accent});

  final String assetPath;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: context.isMobile ? 0.8 : 0.5,
        heightFactor: 1,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.transparent, Colors.white],
            stops: [0, 0.65],
          ).createShader(bounds),
          child: Opacity(
            opacity: 0.2,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                accent.withAlpha(40),
                BlendMode.srcATop,
              ),
              child: SizedBox.expand(
                child: Image.asset(assetPath, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliverablesWidget extends StatelessWidget {
  const _DeliverablesWidget({required this.deliverables});

  final List<String> deliverables;

  @override
  Widget build(BuildContext context) {
    final cardSpacing = context.space(factor: 1.5);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardsPerRow = constraints.maxWidth >= 760 ? 2 : 1;
        final cardWidth =
            (constraints.maxWidth - cardSpacing * (cardsPerRow - 1)) /
            cardsPerRow;

        return Wrap(
          spacing: cardSpacing,
          runSpacing: cardSpacing,
          children: [
            for (final (deliverableIndex, deliverable) in deliverables.indexed)
              SizedBox(
                width: cardWidth,
                child: _DeliverableCardWidget(
                  deliverable: deliverable,
                  index: deliverableIndex + 1,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DeliverableCardWidget extends StatelessWidget {
  const _DeliverableCardWidget({
    required this.deliverable,
    required this.index,
  });

  final String deliverable;
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    final indexLabel = index.toString().padLeft(2, '0');

    return Container(
      constraints: BoxConstraints(minHeight: context.space(factor: 9)),
      padding: EdgeInsets.all(context.space(factor: 1.75)),
      decoration: BoxDecoration(
        color: palette.surface.surface.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        border: Border.all(color: accent.withAlpha(55)),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        spacing: context.space(factor: 1.5),
        children: [
          DSTextWidget(
            indexLabel,
            style: context.typography.emphasizedTitleMedium,
            color: palette.accent,
          ),
          Container(
            width: 1,
            height: context.space(factor: 5),
            color: accent.withAlpha(75),
          ),
          Expanded(
            child: DSTextWidget(
              deliverable,
              style: context.typography.emphasizedBodyMedium,
              color: palette.neutral.grey10,
            ),
          ),
          Container(
            padding: EdgeInsets.all(context.space(factor: 0.5)),
            decoration: BoxDecoration(
              color: accent.withAlpha(28),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 18, color: accent),
          ),
        ],
      ),
    );
  }
}

class _EngagementTypesWidget extends StatelessWidget {
  const _EngagementTypesWidget({required this.types});

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    final engagementIcons = [
      Icons.handshake_outlined,
      Icons.calendar_month_outlined,
      Icons.sync_rounded,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: context.space(factor: 1.25),
          runSpacing: context.space(factor: 1.25),
          children: [
            for (final (typeIndex, engagementType) in types.indexed)
              _EngagementTypeChipWidget(
                type: engagementType,
                icon: engagementIcons[typeIndex % engagementIcons.length],
                maxWidth: constraints.maxWidth,
              ),
          ],
        );
      },
    );
  }
}

class _EngagementTypeChipWidget extends StatelessWidget {
  const _EngagementTypeChipWidget({
    required this.type,
    required this.icon,
    required this.maxWidth,
  });

  final String type;
  final IconData icon;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: _HoverPopWidget(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.space(factor: 1.5),
            vertical: context.space(),
          ),
          decoration: BoxDecoration(
            color: palette.surface.surface.color,
            borderRadius: BorderRadius.circular(
              context.dimen.radiusLevel2.value,
            ),
            border: Border.all(color: accent.withAlpha(65)),
            boxShadow: [
              BoxShadow(
                color: accent.withAlpha(14),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: context.space(),
            children: [
              Container(
                padding: EdgeInsets.all(context.space(factor: 0.75)),
                decoration: BoxDecoration(
                  color: accent.withAlpha(28),
                  borderRadius: BorderRadius.circular(
                    context.dimen.radiusLevel1.value,
                  ),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              Flexible(
                child: DSTextWidget(
                  type,
                  style: context.typography.emphasizedBodyMedium,
                  color: palette.neutral.grey10,
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 15,
                color: accent.withAlpha(190),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechnologyStackWidget extends StatelessWidget {
  const _TechnologyStackWidget({required this.technologies});

  final List<String> technologies;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.space(factor: 1.5),
      runSpacing: context.space(factor: 1.5),
      children: [
        for (final (technologyIndex, technology) in technologies.indexed)
          _TechnologyChipWidget(technology: technology, index: technologyIndex),
      ],
    );
  }
}

class _TechnologyChipWidget extends StatelessWidget {
  const _TechnologyChipWidget({required this.technology, required this.index});

  final String technology;
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;

    return _HoverPopWidget(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 1.25),
          vertical: context.space(factor: 0.85),
        ),
        decoration: BoxDecoration(
          color: palette.surface.surface.color,
          borderRadius: BorderRadius.circular(context.space(factor: 0.75)),
          border: Border.all(color: accent.withAlpha(75)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: 0.75),
          children: [
            Icon(
              index.isEven ? Icons.terminal_rounded : Icons.code_rounded,
              size: 17,
              color: accent,
            ),
            DSTextWidget(
              technology,
              style: context.typography.emphasizedLabelLarge,
              color: palette.neutral.grey10,
            ),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdealForWidget extends StatelessWidget {
  const _IdealForWidget({required this.audiences});

  final List<String> audiences;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.space(factor: 1.5),
      children: [
        for (final (audienceIndex, audience) in audiences.indexed)
          _IdealAudienceCardWidget(audience: audience, index: audienceIndex),
      ],
    );
  }
}

class _IdealAudienceCardWidget extends StatelessWidget {
  const _IdealAudienceCardWidget({required this.audience, required this.index});

  final String audience;
  final int index;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.space(factor: 1.5)),
      decoration: BoxDecoration(
        color: palette.surface.surface.color.withAlpha(150),
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        border: Border.all(color: accent.withAlpha(65)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 1.25),
        children: [
          Container(
            padding: EdgeInsets.all(context.space(factor: 0.5)),
            decoration: BoxDecoration(
              color: accent.withAlpha(28),
              borderRadius: BorderRadius.circular(
                context.dimen.radiusLevel1.value,
              ),
            ),
            child: Icon(
              index.isEven ? Icons.bolt_rounded : Icons.arrow_forward_rounded,
              size: 18,
              color: accent,
            ),
          ),
          Expanded(
            child: DSTextWidget(
              audience,
              style: context.typography.bodyMedium,
              color: palette.neutral.grey10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsWidget extends StatelessWidget {
  const _StepsWidget({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorPalette.accent.color;

    return Column(
      children: steps.mapIndexed((index, step) {
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: context.space(factor: 1.5),
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: accent,
                    child: DSTextWidget(
                      '${index + 1}',
                      style: context.typography.emphasizedLabelMedium,
                      color: context.colorPalette.brand.onTertiary,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: accent.withAlpha(70)),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 3,
                    bottom: isLast ? 0 : context.space(factor: 2),
                  ),
                  child: DSTextWidget(
                    step,
                    style: context.typography.bodyMedium,
                    color: context.colorPalette.neutral.grey9,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
