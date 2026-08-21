part of 'expertise_list_widget.dart';

class _DesktopContentWidget extends StatefulWidget {
  const _DesktopContentWidget({
    required this.allExpertise,
    required this.isVisible,
  });

  final List<ExpertiseEntity> allExpertise;
  final bool isVisible;

  @override
  State<_DesktopContentWidget> createState() => _DesktopContentWidgetState();
}

class _DesktopContentWidgetState extends State<_DesktopContentWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ScrollController _scrollController;
  late List<ExpertiseEntity> _infiniteList;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setupInfiniteList();
    _setupSmoothAnimation();
  }

  void _setupInfiniteList() {
    // Create infinite list with 3 copies for smooth looping
    _infiniteList = [];
    for (int i = 0; i < 3; i++) {
      _infiniteList.addAll(widget.allExpertise);
    }
  }

  void _setupSmoothAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        final cardWidth = _CoreStrengthCard.getHeight(context);
        final spacing = context.space();
        final cardStepWidth = cardWidth + spacing; // Distance for one card

        // Create animation that moves one card at a time
        _animationController = AnimationController(
          duration: 500.milliseconds,
          vsync: this,
        );

        _animation =
            Tween<double>(
              begin: 0.0,
              end: cardStepWidth, // Move exactly one card width + spacing
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
            );

        // Listen to animation changes and update scroll position
        _animation.addListener(() {
          if (_scrollController.hasClients) {
            final currentBasePosition = _currentCardIndex * cardStepWidth;
            final animatedOffset = currentBasePosition + _animation.value;
            _scrollController.jumpTo(animatedOffset);
          }
        });

        _animationController.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            // Move to next card
            _currentCardIndex++;

            // Reset to beginning when reaching the end of the second loop for seamless infinite scroll
            if (_currentCardIndex >= widget.allExpertise.length * 2) {
              _currentCardIndex =
                  widget.allExpertise.length; // Reset to middle section
              _scrollController.jumpTo(_currentCardIndex * cardStepWidth);
            }

            // Pause for 3 second before starting next card transition
            Future.delayed(3.seconds, () {
              if (mounted) {
                _animationController.reset();
                _animationController.forward();
              }
            });
          }
        });

        _animationController.forward();
      }
    });
  }

  int _currentCardIndex = 0; // Track current card position

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          height: _CoreStrengthCard.getHeight(context),
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _infiniteList.length,
            padding: EdgeInsets.symmetric(horizontal: context.space()),
            separatorBuilder: (_, index) => SizedBox(width: context.space()),
            itemBuilder: (context, index) {
              final coreStrength = _infiniteList[index];
              return _CoreStrengthCard(
                coreStrength: coreStrength,
                index: index,
              );
            },
          ),
        )
        .animate(target: widget.isVisible ? 1 : 0)
        .fadeIn(delay: 200.ms, duration: 300.ms);
  }
}

class _CoreStrengthCard extends StatelessWidget {
  const _CoreStrengthCard({required this.coreStrength, required this.index});

  final ExpertiseEntity coreStrength;
  final int index;

  static double getHeight(BuildContext context) {
    return context.space(factor: 2) +
        context.expertiesImageSize +
        context.space(factor: 0.5) +
        _TitleWidget.getHeight(context, 1) +
        context.space(factor: 0.5) +
        1 + // divider thickness
        context.space(factor: 0.5) +
        _SkillsWidget.getHeight(context, 4) +
        context.space(factor: 2);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getHeight(context),
      height: getHeight(context),
      child: DSCardWidget(
        elevation: context.dimen.elevationNone,
        backgroundColor: context.colorPalette.containerHighest,
        radius: context.dimen.radiusLevel2,
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 2)),
          child: Stack(
            children: [
              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: context.space(factor: 0.5),
                children: [
                  _ImageWidget(imageUrl: coreStrength.image),
                  _TitleWidget(
                    title: coreStrength.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  DSHorizontalDividerWidget(
                    thickness: 1,
                    color: context.colorPalette.border,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.space(factor: 0.1),
                      ),
                      child: _SkillsWidget(
                        skills: coreStrength.skills,
                        alignment: WrapAlignment.center,
                      ),
                    ),
                  ),
                ],
              ),
              // Floating accent dot
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colorPalette.brand.primary.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
