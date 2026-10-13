part of 'experience_list_widget.dart';

class _ExperienceCardWidget extends StatefulWidget {
  const _ExperienceCardWidget({
    required this.experience,
    required this.onHoverChange,
  });

  final ExperienceEntity experience;
  final ValueChanged<bool> onHoverChange;

  @override
  State<_ExperienceCardWidget> createState() => _ExperienceCardWidgetState();
}

class _ExperienceCardWidgetState extends State<_ExperienceCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  static const _onCard = DSColor(0xFFFFFFFF);
  static const _onCardMuted = DSColor(0xD9FFFFFF);
  static const _onCardAccent = DSColor(0xFF9CC9FF);

  bool _expanded = false;
  bool _isHovering = false;
  bool _isCompanyHovering = false;
  Offset? _pointer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 450.ms);
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    _expanded ? _controller.reverse() : _controller.forward();
    setState(() => _expanded = !_expanded);
  }

  void _setHover(bool value) {
    setState(() {
      _isHovering = value;
      if (!value) _pointer = null;
    });
    widget.onHoverChange(value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    // The card is always dark so the white text keeps a high contrast in
    // both light and dark themes.
    const base = Color(0xFF0E1726);
    final startColor = Color.lerp(base, accent, 0.22)!;
    final endColor = Color.lerp(base, palette.brand.tertiary.color, 0.18)!;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      onHover: (event) => setState(() => _pointer = event.localPosition),
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovering ? -6 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          border: Border.all(
            color: _isHovering ? Colors.white70 : Colors.white12,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withAlpha(_isHovering ? 70 : 20),
              blurRadius: _isHovering ? 32 : 12,
              offset: Offset(0, _isHovering ? 14 : 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              Positioned.fill(child: _spotlight(accent)),
              _logoWatermark(context),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: 300.ms,
                  height: 3,
                  margin: EdgeInsets.only(
                    right: _isHovering ? 0 : context.space(factor: 20),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, palette.brand.tertiary.color],
                    ),
                  ),
                ),
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: _toggleExpand,
                  child: Padding(
                    padding: EdgeInsets.all(context.space(factor: 2.5)),
                    child: _content(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoWatermark(BuildContext context) {
    final size = context.space(factor: 22);

    return Positioned(
      right: -size * 0.18,
      bottom: -size * 0.18,
      child: IgnorePointer(
        child: AnimatedRotation(
          turns: _isHovering ? -0.03 : -0.06,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: _isHovering ? 1.15 : 1,
            duration: 600.ms,
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: _isHovering ? 0.16 : 0.07,
              duration: 400.ms,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                child: DSNetworkImageWidget(
                  url: widget.experience.companyLogo,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _spotlight(Color accent) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pointer = _pointer;
          final alignment = pointer == null || constraints.maxWidth == 0
              ? Alignment.topRight
              : Alignment(
                  (pointer.dx / constraints.maxWidth) * 2 - 1,
                  (pointer.dy / constraints.maxHeight.clamp(1, 4000)) * 2 - 1,
                );
          return AnimatedOpacity(
            duration: 300.ms,
            opacity: _isHovering ? 1 : 0.35,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: alignment,
                  radius: 0.9,
                  colors: [Colors.white.withAlpha(24), Colors.transparent],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _companyName(BuildContext context) {
    final experience = widget.experience;
    final url = experience.url;
    final text = DSTextWidget(
      '${context.localizations.atCompany} ${experience.company}',
      style: context.typography.emphasizedTitleSmall,
      color: _onCardAccent,
    );
    if (url == null || url.isEmpty) return text;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isCompanyHovering = true),
      onExit: (_) => setState(() => _isCompanyHovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _isCompanyHovering
                    ? _onCardAccent.color
                    : Colors.transparent,
              ),
            ),
          ),
          child: text,
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final experience = widget.experience;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSTextWidget(
                    experience.position,
                    style: context.typography.emphasizedTitleLarge,
                    color: _onCard,
                  ),
                  const DSVerticalSpacerWidget(0.5),
                  _companyName(context),
                ],
              ),
            ),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: 300.ms,
              curve: Curves.easeOut,
              child: Icon(Icons.expand_more_rounded, color: _onCard.color),
            ),
          ],
        ),
        const DSVerticalSpacerWidget(1.5),
        Wrap(
          spacing: context.space(factor: 2),
          runSpacing: context.space(factor: 0.5),
          children: [
            _ItemWidget(
              icon: Icons.calendar_month_rounded,
              label: experience.formattedDateRange(context),
              color: _onCardMuted,
            ),
            _ItemWidget(
              icon: Icons.pin_drop,
              label: experience.location,
              color: _onCardMuted,
            ),
            _ItemWidget(
              icon: Icons.work,
              label: experience.employmentType,
              color: _onCardMuted,
            ),
          ],
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => _controller.isDismissed
              ? const SizedBox.shrink()
              : ClipRect(
                  child: SizeTransition(
                    sizeFactor: _expandAnimation,
                    alignment: Alignment.topCenter,
                    child: _expandedContent(context),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _expandedContent(BuildContext context) {
    final experience = widget.experience;

    return Padding(
      padding: EdgeInsets.only(top: context.space(factor: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DescriptionWidget(
            description: experience.description,
            color: _onCardMuted,
          ),
          const DSVerticalSpacerWidget(1.5),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton.filled(
              tooltip: context.localizations.seeMore,
              icon: const Icon(Icons.arrow_outward_rounded),
              onPressed: () {
                ExperienceScreen.navigate(context, id: experience.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}
