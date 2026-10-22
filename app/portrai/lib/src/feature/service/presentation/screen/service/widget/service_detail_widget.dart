part of 'content_widget.dart';

class _DetailQuoteBandWidget extends StatefulWidget {
  const _DetailQuoteBandWidget({required this.detail, required this.imageUrl});

  final String detail;
  final String imageUrl;

  @override
  State<_DetailQuoteBandWidget> createState() => _DetailQuoteBandWidgetState();
}

class _DetailQuoteBandWidgetState extends State<_DetailQuoteBandWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _imageController;

  @override
  void initState() {
    super.initState();
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isMobile = context.isMobile;
    final quoteBackground = palette.surface.inverseSurface.color;
    final quoteGradientEnd = Color.alphaBlend(
      palette.accent.color.withAlpha(72),
      quoteBackground,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          end: Alignment.bottomRight,
          colors: [quoteBackground, quoteGradientEnd],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _imageController,
                builder: (context, _) {
                  final floatOffset = (_imageController.value - 0.5) * 8;

                  return Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: isMobile ? 0.55 : 0.42,
                      heightFactor: 1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: context.space(),
                        ),
                        child: Transform.translate(
                          offset: Offset(0, floatOffset),
                          child: Opacity(
                            opacity: 0.38,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                palette.accent.color,
                                BlendMode.srcATop,
                              ),
                              child: SizedBox.expand(
                                child: DSNetworkImageWidget(
                                  url: widget.imageUrl,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: context.screenHorizontalPadding.copyWith(
                top: context.space(factor: 6),
                bottom: context.space(factor: 6),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: context.space(factor: 2),
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: context.isMobile ? 34 : 42,
                        color: palette.accent.color,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: context.space()),
                          child: DSTextWidget(
                            widget.detail,
                            style: context.typography.bodyLarge,
                            color: palette.surface.onInverseSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Details of a [ServiceEntity], laid out as a column of styled sections.
class _ServiceDetailWidget extends StatelessWidget {
  const _ServiceDetailWidget({required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final sections = [
      if (service.deliverables.isNotEmpty)
        (
          title: localizations.serviceDetailDeliverables,
          icon: Icons.inventory_2_outlined,
          backgroundAsset: null,
          child: _DeliverablesWidget(deliverables: service.deliverables),
        ),
      if (service.process.isNotEmpty)
        (
          title: localizations.serviceDetailProcess,
          icon: Icons.route_outlined,
          backgroundAsset: null,
          child: _StepsWidget(steps: service.process),
        ),
      if (service.technologies.isNotEmpty)
        (
          title: localizations.serviceDetailTechnologies,
          icon: Icons.code_rounded,
          backgroundAsset: 'assets/service/technology_background.jpg',
          child: _TechnologyStackWidget(technologies: service.technologies),
        ),
      if (service.idealFor.isNotEmpty)
        (
          title: localizations.serviceDetailIdealFor,
          icon: Icons.track_changes_rounded,
          backgroundAsset: null,
          child: _IdealForWidget(audiences: service.idealFor),
        ),
      if (service.engagementTypes.isNotEmpty)
        (
          title: localizations.serviceDetailEngagement,
          icon: Icons.handshake_outlined,
          backgroundAsset: null,
          child: _EngagementTypesWidget(types: service.engagementTypes),
        ),
      if (service.faq.isNotEmpty)
        (
          title: localizations.serviceDetailFaq,
          icon: Icons.help_outline_rounded,
          backgroundAsset: 'assets/service/faq_background.jpg',
          child: _FaqWidget(faq: service.faq),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RevealWidget(
          child: DSOffscreenPauseWidget(
            child: _DetailQuoteBandWidget(
              detail: service.detail,
              imageUrl: service.image,
            ),
          ),
        ),
        for (final (sectionIndex, section) in sections.indexed)
          _SectionWidget(
            title: section.title,
            icon: section.icon,
            isAlternate: sectionIndex.isOdd,
            backgroundAsset: section.backgroundAsset,
            child: section.child,
          ),
      ],
    );
  }
}
