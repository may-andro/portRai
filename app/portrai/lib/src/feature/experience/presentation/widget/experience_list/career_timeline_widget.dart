part of 'experience_list_widget.dart';

class _CareerTimelineWidget extends StatelessWidget {
  const _CareerTimelineWidget({
    required this.experiences,
    required this.isVisible,
    required this.isZigZag,
    required this.onClicked,
  });

  final List<ExperienceEntity> experiences;
  final bool isVisible;
  final bool isZigZag;
  final ValueChanged<ExperienceEntity> onClicked;

  static double nodeSize(BuildContext context) => context.space(factor: 7);

  @override
  Widget build(BuildContext context) {
    if (experiences.isEmpty) {
      return const SizedBox.shrink();
    }

    final node = nodeSize(context);
    final palette = context.colorPalette;

    final spine =
        Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.brand.primary.color,
                    palette.brand.tertiary.color,
                    palette.brand.tertiary.color.withAlpha(0),
                  ],
                ),
              ),
            )
            .animate(target: isVisible ? 1 : 0)
            .scaleY(
              begin: 0,
              alignment: Alignment.topCenter,
              duration: 1400.ms,
              curve: Curves.easeOutCubic,
            );

    // Room for the hover lift, glow and pulsing ring that the section clips.
    final padding = EdgeInsets.fromLTRB(
      isZigZag ? 0 : node * 0.4,
      context.space(factor: 3),
      0,
      context.space(factor: 4),
    );

    return Padding(
      padding: padding,
      child: Stack(
        children: [
          Positioned(
            top: node / 2,
            bottom: 0,
            left: isZigZag ? 0 : node / 2 - 1,
            right: isZigZag ? 0 : null,
            child: isZigZag ? Center(child: spine) : spine,
          ),
          Column(
            children: [
              for (final (index, experience) in experiences.indexed)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: index == experiences.length - 1
                        ? 0
                        : context.space(factor: isZigZag ? 6 : 3),
                  ),
                  child: _TimelineRowWidget(
                    experience: experience,
                    index: index,
                    isVisible: isVisible,
                    isZigZag: isZigZag,
                    nodeSize: node,
                    onClicked: onClicked,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineRowWidget extends StatefulWidget {
  const _TimelineRowWidget({
    required this.experience,
    required this.index,
    required this.isVisible,
    required this.isZigZag,
    required this.nodeSize,
    required this.onClicked,
  });

  final ExperienceEntity experience;
  final int index;
  final bool isVisible;
  final bool isZigZag;
  final double nodeSize;
  final ValueChanged<ExperienceEntity> onClicked;

  @override
  State<_TimelineRowWidget> createState() => _TimelineRowWidgetState();
}

class _TimelineRowWidgetState extends State<_TimelineRowWidget> {
  bool _isHovering = false;

  bool get _isLeft => widget.isZigZag && widget.index.isEven;

  @override
  Widget build(BuildContext context) {
    final delay = (300 + widget.index * 180).ms;
    final slideFrom = widget.isZigZag ? (_isLeft ? -0.12 : 0.12) : 0.0;

    final card =
        _ExperienceCardWidget(
              experience: widget.experience,
              onHoverChange: (value) => setState(() => _isHovering = value),
              onClicked: widget.onClicked,
            )
            .animate(target: widget.isVisible ? 1 : 0)
            .slide(
              begin: Offset(slideFrom, widget.isZigZag ? 0 : 0.15),
              end: Offset.zero,
              duration: 600.ms,
              delay: delay,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(delay: delay, duration: 500.ms);

    final node = _TimelineNodeWidget(
      experience: widget.experience,
      size: widget.nodeSize,
      isHovering: _isHovering,
      isVisible: widget.isVisible,
      delay: delay,
    );

    if (!widget.isZigZag) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          node,
          SizedBox(width: context.space(factor: 2)),
          Expanded(child: card),
        ],
      );
    }

    final year = _YearWatermarkWidget(
      year: widget.experience.startDate.year,
      isVisible: widget.isVisible,
      delay: delay,
      alignment: _isLeft ? Alignment.centerLeft : Alignment.centerRight,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _isLeft ? card : year),
        SizedBox(width: context.space(factor: 3)),
        node,
        SizedBox(width: context.space(factor: 3)),
        Expanded(child: _isLeft ? year : card),
      ],
    );
  }
}

class _TimelineNodeWidget extends StatelessWidget {
  const _TimelineNodeWidget({
    required this.experience,
    required this.size,
    required this.isHovering,
    required this.isVisible,
    required this.delay,
  });

  final ExperienceEntity experience;
  final double size;
  final bool isHovering;
  final bool isVisible;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorPalette.brand.primary.color;
    final isCurrent = experience.endDate == null;

    return DSOffscreenPauseWidget(
      child:
          SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (isCurrent)
                      Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: accent, width: 2),
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.7, 1.7),
                            duration: 1800.ms,
                            curve: Curves.easeOut,
                          )
                          .fadeOut(duration: 1800.ms, curve: Curves.easeOut),
                    AnimatedContainer(
                      duration: 250.ms,
                      width: size,
                      height: size,
                      padding: EdgeInsets.all(size * 0.14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: accent,
                          width: isHovering ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withAlpha(isHovering ? 130 : 60),
                            blurRadius: isHovering ? 22 : 10,
                          ),
                        ],
                      ),
                      child: AnimatedRotation(
                        turns: isHovering ? 0.03 : 0,
                        duration: 300.ms,
                        curve: Curves.easeOutBack,
                        child: _ImageWidget(
                          experience: experience,
                          size: size,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate(target: isVisible ? 1 : 0)
              .scale(
                begin: Offset.zero,
                end: const Offset(1, 1),
                duration: 600.ms,
                delay: delay,
                curve: Curves.elasticOut,
              ),
    );
  }
}

class _YearWatermarkWidget extends StatelessWidget {
  const _YearWatermarkWidget({
    required this.year,
    required this.isVisible,
    required this.delay,
    required this.alignment,
  });

  final int year;
  final bool isVisible;
  final Duration delay;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final color = context.colorPalette.brand.primary.color;

    return Align(
      alignment: alignment,
      child:
          Text(
                '$year',
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -2,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.5
                    ..color = color.withAlpha(110),
                ),
              )
              .animate(target: isVisible ? 1 : 0)
              .fadeIn(delay: delay + 200.ms, duration: 700.ms)
              .slideY(
                begin: 0.3,
                delay: delay + 200.ms,
                duration: 700.ms,
                curve: Curves.easeOutCubic,
              ),
    );
  }
}
