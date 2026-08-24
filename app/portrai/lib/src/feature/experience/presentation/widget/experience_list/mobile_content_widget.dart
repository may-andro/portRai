part of 'experience_list_widget.dart';

class _MobileContentWidget extends StatelessWidget {
  const _MobileContentWidget({
    required this.experiences,
    required this.isVisible,
  });

  final List<ExperienceEntity> experiences;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        return _MobileItemWidget(experience: experiences[index])
            .animate(target: isVisible ? 1 : 0)
            .slideY(
              begin: 1 + (index * 0.2),
              duration: 300.ms,
              delay: (100 + index * 100).ms,
              curve: Curves.easeOut,
            )
            .fadeIn(delay: (300 + index * 100).ms, duration: 300.ms);
      },
      separatorBuilder: (_, index) => const DSVerticalSpacerWidget(2),
    );
  }
}

class _MobileItemWidget extends StatefulWidget {
  const _MobileItemWidget({required this.experience});

  final ExperienceEntity experience;

  @override
  State<_MobileItemWidget> createState() => _MobileItemWidgetState();
}

class _MobileItemWidgetState extends State<_MobileItemWidget>
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

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(context.dimen.radiusLevel1.value),
      bottomRight: Radius.circular(context.dimen.radiusLevel3.value),
      topRight: Radius.circular(context.dimen.radiusLevel1.value),
      bottomLeft: Radius.circular(context.dimen.radiusLevel1.value),
    );

    return AnimatedContainer(
      duration: 400.ms,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: cardColor.withAlpha(200),
            blurRadius: context.dimen.radiusLevel1.value,
            offset: const Offset(0, 0.3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: InkWell(
          onTap: _toggleExpand,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Header ----------------
              _MobileHeaderWidget(
                experience: widget.experience,
                expanded: _expanded,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(factor: 2),
                ),
                child: _DateLocationWidget(experience: widget.experience),
              ),
              const DSVerticalSpacerWidget(2),
              // ---------------- Expandable Content ----------------
              _MobileExpandedWidget(
                experience: widget.experience,
                expandAnimation: _expandAnimation,
                isVisible: _expanded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileHeaderWidget extends StatelessWidget {
  const _MobileHeaderWidget({required this.experience, required this.expanded});

  final ExperienceEntity experience;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.space(factor: 2)),
      child: Row(
        children: [
          _ImageWidget(experience: experience, size: context.space(factor: 8)),
          const DSHorizontalSpacerWidget(2),
          Expanded(child: _TitlePositionWidget(experience: experience)),
          AnimatedRotation(
            turns: expanded ? 0.5 : 0,
            duration: 300.ms,
            curve: Curves.easeOut,
            child: DSIconWidget(
              Icons.arrow_drop_down,
              color: context.colorPalette.neutral.grey9,
              size: DSIconSize.large,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileExpandedWidget extends StatelessWidget {
  const _MobileExpandedWidget({
    required this.experience,
    required this.expandAnimation,
    required this.isVisible,
  });

  final ExperienceEntity experience;
  final Animation<double> expandAnimation;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizeTransition(
        sizeFactor: expandAnimation,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.space(factor: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DescriptionWidget(description: experience.description)
                  .animate(target: isVisible ? 1 : 0)
                  .slideY(
                    begin: 0.3,
                    duration: 300.ms,
                    delay: 100.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(delay: 100.ms, duration: 300.ms),
              const DSVerticalSpacerWidget(1),
              _TechnologiesWidget(
                technologies: experience.technologies,
                isVisible: isVisible,
              ),
              const DSVerticalSpacerWidget(1),
              Align(
                    alignment: Alignment.bottomRight,
                    child: FittedBox(
                      child: DSButtonWidget(
                        label: 'See More',
                        variant: DSButtonVariant.secondary,
                        size: DSButtonSize.extraSmall,
                        icon: Icons.chevron_right_rounded,
                        iconDirection: DSButtonIconDirection.right,
                        onPressed: () {
                          ExperienceScreen.navigate(context, id: experience.id);
                        },
                      ),
                    ),
                  )
                  .animate(target: isVisible ? 1 : 0)
                  .slideX(
                    begin: 0.3,
                    duration: 300.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(delay: 400.ms, duration: 300.ms),
              const DSVerticalSpacerWidget(2),
            ],
          ),
        ),
      ),
    );
  }
}
