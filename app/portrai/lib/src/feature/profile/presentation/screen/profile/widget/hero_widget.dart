part of 'content_widget.dart';

/// Landing hero: intro copy on one side, a fixed portrait on a leaf-shaped
/// plate on the other, with the remaining photos floating in the background.
class _HeroWidget extends StatelessWidget {
  const _HeroWidget({required this.profile, required this.isDesktop});

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final portraitWidth = isDesktop
        ? min(context.width * 0.26, 400.0)
        : min(context.width * 0.62, 280.0);
    final stageWidth = portraitWidth * (isDesktop ? 1.55 : 1.35);
    final stage = _HeroStageWidget(
      profile: profile,
      portraitWidth: portraitWidth,
      stageWidth: stageWidth,
    );

    return ClipRect(
      child: Stack(
        children: [
          const Positioned.fill(child: _HeroBackgroundWidget()),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _horizontalInset(context),
              vertical: context.space(factor: isDesktop ? 6 : 4),
            ),
            child: SizedBox(
              width: double.infinity,
              child: isDesktop
                  ? Row(
                      spacing: context.space(factor: 4),
                      children: [
                        Expanded(
                          child: _HeroTextWidget(
                            profile: profile,
                            isDesktop: true,
                          ),
                        ),
                        stage,
                      ],
                    )
                  : Column(
                      spacing: context.space(factor: 3),
                      children: [
                        stage,
                        _HeroTextWidget(profile: profile, isDesktop: false),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBackgroundWidget extends StatelessWidget {
  const _HeroBackgroundWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    Widget blob(Color from, Color to, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [from.withAlpha(70), to.withAlpha(20)],
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.surface.surface.color,
            palette.brand.primaryContainer.color.withAlpha(80),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = max(constraints.maxWidth * 0.55, 320.0);
          return Stack(
            children: [
              Positioned(
                right: -size * 0.25,
                top: -size * 0.3,
                child:
                    blob(
                          palette.brand.primary.color,
                          palette.brand.secondary.color,
                          size,
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .move(
                          begin: Offset.zero,
                          end: const Offset(-24, 18),
                          duration: 9.seconds,
                          curve: Curves.easeInOut,
                        ),
              ),
              Positioned(
                left: -size * 0.2,
                bottom: -size * 0.35,
                child:
                    blob(
                          palette.brand.secondary.color,
                          palette.brand.primary.color,
                          size * 0.7,
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .move(
                          begin: Offset.zero,
                          end: const Offset(20, -16),
                          duration: 11.seconds,
                          curve: Curves.easeInOut,
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroTextWidget extends StatelessWidget {
  const _HeroTextWidget({required this.profile, required this.isDesktop});

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final align = isDesktop
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final textAlign = isDesktop ? TextAlign.start : TextAlign.center;

    return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: align,
          spacing: context.space(factor: 1.5),
          children: [
            _OpenToWorkPillWidget(status: profile.availability.status),
            DSTextWidget(
              profile.fullName,
              style: isDesktop
                  ? context.typography.emphasizedDisplayMedium
                  : context.typography.emphasizedHeadlineLarge,
              color: palette.neutral.grey10,
              textAlign: textAlign,
            ),
            DSTextWidget(
              profile.subtitle,
              style: isDesktop
                  ? context.typography.emphasizedHeadlineSmall
                  : context.typography.emphasizedTitleMedium,
              color: palette.brand.primary,
              textAlign: textAlign,
            ),
            DSTextWidget(
              profile.uniqueValueProposition,
              style: context.typography.bodyLarge,
              color: palette.neutral.grey8,
              textAlign: textAlign,
            ),
            SizedBox(height: context.space(factor: 0.5)),
            Wrap(
              alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
              spacing: context.space(factor: 2),
              runSpacing: context.space(factor: 2),
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _WebButtonWidget(
                  label: context.localizations.profileHireMe,
                  icon: Icons.arrow_outward_rounded,
                  onPressed: () => context.bloc.add(
                    OpenExternalUrlEvent(
                      url: 'mailto:${profile.email}',
                      label: 'Email',
                    ),
                  ),
                ),
                for (final link in profile.socialLinks.where(
                  (link) =>
                      ['github', 'linkedin'].contains(link.name.toLowerCase()),
                ))
                  _SocialIconButtonWidget(link: link),
              ],
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(
          begin: isDesktop ? -0.08 : 0,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Green pulsing pill telling recruiters the owner can be hired right now.
class _OpenToWorkPillWidget extends StatelessWidget {
  const _OpenToWorkPillWidget({required this.status});

  final String status;

  static const _green = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.5),
        vertical: context.space(factor: 0.75),
      ),
      decoration: BoxDecoration(
        color: _green.withAlpha(30),
        borderRadius: BorderRadius.circular(context.dimen.radiusCircular.value),
        border: Border.all(color: _green.withAlpha(110)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 1.25),
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _green.withAlpha(90),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.4, 1.4),
                      duration: 1600.ms,
                    )
                    .fadeOut(duration: 1600.ms),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: DSTextWidget(
              status,
              style: context.typography.emphasizedLabelLarge,
              color: context.colorPalette.neutral.grey10,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStageWidget extends StatelessWidget {
  const _HeroStageWidget({
    required this.profile,
    required this.portraitWidth,
    required this.stageWidth,
  });

  final ProfileEntity profile;
  final double portraitWidth;
  final double stageWidth;

  @override
  Widget build(BuildContext context) {
    final portraitHeight = portraitWidth * 1.2;
    final stageHeight = portraitHeight * 1.12;
    final cardSize = portraitWidth * 0.32;
    final extras = profile.backdropImages;
    final slots = [
      (left: 0.0, top: stageHeight * 0.04, turns: -0.025, delay: 0),
      (
        left: stageWidth - cardSize,
        top: stageHeight * 0.30,
        turns: 0.02,
        delay: 700,
      ),
      (
        left: stageWidth - cardSize * 1.05,
        top: stageHeight - cardSize * 1.3,
        turns: 0.015,
        delay: 1400,
      ),
    ];

    return SizedBox(
      width: stageWidth,
      height: stageHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: _HeroPortraitWidget(
              url: profile.coverImage,
              width: portraitWidth,
              height: portraitHeight,
            ),
          ),
          for (
            var slotIndex = 0;
            slotIndex < extras.length && slotIndex < slots.length;
            slotIndex++
          )
            Positioned(
              left: slots[slotIndex].left,
              top: slots[slotIndex].top,
              child: _FloatingPhotoWidget(
                url: extras[slotIndex],
                size: cardSize,
                turns: slots[slotIndex].turns,
                delay: slots[slotIndex].delay,
              ),
            ),
          Positioned(
            left: stageWidth * 0.06,
            bottom: stageHeight * 0.02,
            child: _HeroChipWidget(
              icon: Icons.workspace_premium_rounded,
              label:
                  '${profile.yearsOfExperience}+ ${context.localizations.profileYearsExperience}',
              delay: 300,
            ),
          ),
          Positioned(
            right: stageWidth * 0.0,
            top: stageHeight * 0.01,
            child: _HeroChipWidget(
              icon: Icons.circle,
              iconSize: 10,
              iconColor: const Color(0xFF22C55E),
              label: context.localizations.profileAvailableForWork,
              delay: 1000,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPortraitWidget extends StatelessWidget {
  const _HeroPortraitWidget({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;

  BorderRadius get _shape => BorderRadius.only(
    topLeft: Radius.circular(width * 0.45),
    topRight: const Radius.circular(28),
    bottomLeft: const Radius.circular(28),
    bottomRight: Radius.circular(width * 0.45),
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return _HoverLiftWidget(
          scale: 1.03,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Transform.translate(
                    offset: const Offset(18, 18),
                    child: Transform.rotate(
                      angle: 0.06,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: _shape,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              palette.brand.primary.color,
                              palette.brand.secondary.color,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Transform.translate(
                    offset: const Offset(-14, -10),
                    child: Transform.rotate(
                      angle: -0.04,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: _shape,
                          border: Border.all(
                            color: palette.brand.primary.color.withAlpha(120),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: _shape,
                      boxShadow: [
                        BoxShadow(
                          color: palette.brand.primary.color.withAlpha(70),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: _shape,
                      child: ColoredBox(
                        color: palette.surface.surface.color,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: context.space(),
                            right: context.space(),
                          ),
                          child: DSNetworkImageWidget(
                            url: url,
                            fit: BoxFit.contain,
                            width: width,
                            height: height,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: 800.ms,
          curve: Curves.easeOutBack,
        );
  }
}

/// A tilted, gently floating photo that straightens and rises on hover.
class _FloatingPhotoWidget extends StatefulWidget {
  const _FloatingPhotoWidget({
    required this.url,
    required this.size,
    required this.turns,
    required this.delay,
  });

  final String url;
  final double size;
  final double turns;
  final int delay;

  @override
  State<_FloatingPhotoWidget> createState() => _FloatingPhotoWidgetState();
}

class _FloatingPhotoWidgetState extends State<_FloatingPhotoWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: AnimatedRotation(
            turns: _hovering ? 0 : widget.turns,
            duration: const Duration(milliseconds: 250),
            child: AnimatedScale(
              scale: _hovering ? 1.12 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: Container(
                width: widget.size,
                height: widget.size,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: palette.surface.surface.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: palette.brand.primary.color.withAlpha(
                        _hovering ? 90 : 45,
                      ),
                      blurRadius: _hovering ? 28 : 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DSNetworkImageWidget(
                    url: widget.url,
                    fit: BoxFit.fitHeight,
                    width: widget.size,
                    height: widget.size,
                  ),
                ),
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(
          begin: -6,
          end: 6,
          delay: widget.delay.ms,
          duration: 3.seconds,
          curve: Curves.easeInOut,
        );
  }
}

class _HeroChipWidget extends StatelessWidget {
  const _HeroChipWidget({
    required this.icon,
    required this.label,
    required this.delay,
    this.iconSize = 18,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final int delay;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return _HoverLiftWidget(
      scale: 1.06,
      child:
          Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(factor: 1.5),
                  vertical: context.space(factor: 0.75),
                ),
                decoration: BoxDecoration(
                  color: palette.surface.surface.color,
                  borderRadius: BorderRadius.circular(
                    context.dimen.radiusCircular.value,
                  ),
                  border: Border.all(
                    color: palette.brand.primary.color.withAlpha(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: context.space(factor: 0.75),
                  children: [
                    Icon(
                      icon,
                      size: iconSize,
                      color: iconColor ?? palette.brand.primary.color,
                    ),
                    DSTextWidget(
                      label,
                      style: context.typography.emphasizedLabelLarge,
                      color: palette.neutral.grey10,
                    ),
                  ],
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: 4,
                end: -4,
                delay: delay.ms,
                duration: 2.5.seconds,
                curve: Curves.easeInOut,
              ),
    );
  }
}

class _SocialIconButtonWidget extends StatelessWidget {
  const _SocialIconButtonWidget({required this.link});

  final SocialLinkEntity link;

  @override
  Widget build(BuildContext context) {
    return _HoverLiftWidget(
      scale: 1.1,
      child: Tooltip(
        message: link.name,
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          shadowColor: Colors.black.withAlpha(60),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.bloc.add(
              OpenExternalUrlEvent(url: link.url, label: link.name),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DSNetworkImageWidget(
                url: link.image,
                width: 24,
                height: 24,
                fit: BoxFit.fitHeight,
                errorWidget: const Icon(Icons.link_rounded, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
