part of 'experience_list_widget.dart';

class _DesktopContentWidget extends StatelessWidget {
  const _DesktopContentWidget({
    required this.experiences,
    required this.isVisible,
  });

  final List<ExperienceEntity> experiences;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        // Vertical timeline line
        Positioned.fill(
          left: context.space(factor: 2.5),
          child:
              Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.only(top: context.space(factor: 3)),
                      width: context.space(factor: 0.2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            context.colorPalette.brand.primary.color.withAlpha(
                              200,
                            ),
                            context.colorPalette.brand.secondary.color
                                .withAlpha(200),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate(target: isVisible ? 1 : 0)
                  .slideY(
                    begin: 1,
                    end: 0,
                    duration: 300.ms,
                    delay: 200.ms,
                    curve: Curves.decelerate,
                  )
                  .fadeIn(delay: 100.ms, duration: 300.ms),
        ),
        // Timeline content
        ListView.separated(
          itemCount: experiences.length + 1,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          separatorBuilder: (_, index) {
            return const DSVerticalSpacerWidget(2);
          },
          itemBuilder: (context, index) {
            if (index == 0) {
              return const DSVerticalSpacerWidget(0.2);
            }
            final experience = experiences[index - 1];
            return _DesktopItemWidget(experience: experience)
                .animate(target: isVisible ? 1 : 0)
                .slideX(
                  begin: 1 + (index * 0.2),
                  duration: 300.ms,
                  delay: (100 + index * 100).ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(delay: (300 + index * 100).ms, duration: 300.ms);
          },
        ),
        Positioned(
          bottom: 0,
          left: context.space(factor: 1.6 - 0.125),
          child: Container(
            width: context.space(factor: 2),
            height: context.space(factor: 2),
            decoration: BoxDecoration(
              color: context.colorPalette.brand.secondary.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopItemWidget extends StatelessWidget {
  const _DesktopItemWidget({required this.experience});

  final ExperienceEntity experience;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        // Timeline Node (the circular icon)
        Container(
          height: context.space(factor: 5),
          width: context.space(factor: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colorPalette.surface.surfaceContainerHighest.color,
            border: Border.all(
              color: context.colorPalette.brand.primary.color,
              width: context.space(factor: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: context.colorPalette.brand.primary.color.withAlpha(100),
                blurRadius: context.space(),
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _ImageWidget(
            experience: experience,
            size: context.space(factor: 5),
            shape: BoxShape.circle,
          ),
        ),
        // Card + Pointer
        _TimelineCard(experience: experience),
      ],
    );
  }
}

class _TimelineCard extends StatefulWidget {
  const _TimelineCard({required this.experience});

  final ExperienceEntity experience;

  @override
  State<_TimelineCard> createState() => _TimelineCardState();
}

class _TimelineCardState extends State<_TimelineCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 400.ms);
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  void _toggleExpand() {
    if (_expanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _expanded = !_expanded);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor =
        context.colorPalette.surface.surfaceContainerHighest.color;

    return GestureDetector(
      onTap: () {},
      child: Stack(
        children: [
          // Pointer triangle (connects card to center line)
          Positioned(
            top: context.space(factor: 1.25),
            left: context.space(factor: 7),
            child: CustomPaint(
              size: Size(
                context.space(factor: 2.5),
                context.space(factor: 2.5),
              ),
              painter: _PointerPainter(color: cardColor),
            ),
          ),
          // Experience card
          Container(
            padding: EdgeInsets.all(context.space(factor: 2)),
            margin: EdgeInsets.only(left: context.space(factor: 8)),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(
                context.dimen.radiusLevel1.value,
              ),
              boxShadow: [
                BoxShadow(
                  color: cardColor.withAlpha(25),
                  blurRadius: context.space(factor: 1.5),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                context.dimen.radiusLevel1.value,
              ),
              child: InkWell(
                onTap: _toggleExpand,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DesktopHeaderWidget(
                      experience: widget.experience,
                      expanded: _expanded,
                    ),
                    const DSVerticalSpacerWidget(1),
                    _DescriptionWidget(
                      description: widget.experience.description,
                    ),
                    _DesktopExpandedWidget(
                      experience: widget.experience,
                      expandAnimation: _expandAnimation,
                      isVisible: _expanded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopHeaderWidget extends StatelessWidget {
  const _DesktopHeaderWidget({
    required this.experience,
    required this.expanded,
  });

  final ExperienceEntity experience;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(factor: 0.3),
            children: [
              _TitlePositionWidget(
                experience: experience,
                isVerticalAligned: false,
              ),
              _DateLocationWidget(
                experience: experience,
                isVerticalAligned: false,
              ),
            ],
          ),
        ),
        AnimatedRotation(
          turns: expanded ? 0.5 : 0,
          duration: 300.ms,
          curve: Curves.easeOut,
          child: DSIconWidget(
            Icons.arrow_drop_down,
            color: context.colorPalette.surface.onSurface,
            size: DSIconSize.large,
          ),
        ),
      ],
    );
  }
}

class _DesktopExpandedWidget extends StatelessWidget {
  const _DesktopExpandedWidget({
    required this.experience,
    required this.expandAnimation,
    required this.isVisible,
  });

  final ExperienceEntity experience;
  final Animation<double> expandAnimation;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final color = context.colorPalette.neutral.grey7;
    return ClipRect(
      child: SizeTransition(
        sizeFactor: expandAnimation,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DSVerticalSpacerWidget(1),
            DSTextWidget(
                  'Achievements & Responsibilities',
                  color: color,
                  style: context.typography.emphasizedLabelLarge,
                )
                .animate(target: isVisible ? 1 : 0)
                .slideY(
                  begin: -0.5,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(duration: 300.ms, delay: 100.ms),
            const DSVerticalSpacerWidget(0.5),
            _ResponsibilitiesWidget(
              responsibilities: experience.responsibilities,
              isVisible: isVisible,
            ),
            const DSVerticalSpacerWidget(1),
            _TechnologiesWidget(
              technologies: experience.technologies,
              isVisible: isVisible,
            ),
          ],
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  _PointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(size.width, 0);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width, size.height);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
