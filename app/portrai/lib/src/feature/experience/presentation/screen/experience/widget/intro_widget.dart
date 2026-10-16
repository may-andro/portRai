import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/extension/experience_date_range_extension.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_band_widget.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key, required this.experience});

  final ExperienceEntity experience;

  static const _onHero = DSColor(0xFFFFFFFF);
  static const _onHeroMuted = DSColor(0xD9FFFFFF);
  static const _onHeroAccent = DSColor(0xFF9CC9FF);

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    const base = Color(0xFF0E1726);
    final start = Color.lerp(base, palette.brand.primary.color, 0.25)!;
    final end = Color.lerp(base, palette.brand.tertiary.color, 0.2)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Judge by the card's own width, not the device, so it never gets squeezed.
        final isMobile = constraints.maxWidth < 760;
        return _buildHero(context, isMobile, start, end);
      },
    );
  }

  Widget _buildHero(
    BuildContext context,
    bool isMobile,
    Color start,
    Color end,
  ) {
    final palette = context.colorPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              right: -context.space(factor: 10),
              top: -context.space(factor: 10),
              child: _GlowWidget(
                color: palette.brand.primary.color,
                driftX: -40,
                driftY: 30,
              ),
            ),
            Positioned(
              left: -context.space(factor: 12),
              bottom: -context.space(factor: 12),
              child: _GlowWidget(
                color: palette.brand.tertiary.color,
                driftX: 50,
                driftY: -30,
              ),
            ),
            Positioned.fill(child: _PatternWidget()),
            Positioned.fill(
              child: DSFloatingShapesBackgroundWidget(
                color: Colors.white.withAlpha(60),
                shapeCount: 22,
              ),
            ),
            const Positioned.fill(child: _SheenWidget()),
            _WatermarkWidget(experience: experience, isMobile: isMobile),
            PageChromeWidget(
              closeColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: pageHorizontalInset(context),
                  vertical: context.space(factor: isMobile ? 4 : 8),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: context.space(factor: 2.5),
                        children: [
                          _LogoWidget(
                            experience: experience,
                            compact: isMobile,
                          ),
                          _TitleBlockWidget(
                            experience: experience,
                            compact: isMobile,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: context.space(factor: 4),
                        children: [
                          Row(
                            spacing: context.space(factor: 4),
                            children: [
                              _LogoWidget(
                                experience: experience,
                                compact: isMobile,
                              ),
                              Expanded(
                                child: _TitleBlockWidget(
                                  experience: experience,
                                  compact: isMobile,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

/// Dot grid that slowly pans diagonally, like a moving texture.
class _PatternWidget extends StatefulWidget {
  @override
  State<_PatternWidget> createState() => _PatternWidgetState();
}

class _PatternWidgetState extends State<_PatternWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: 12.seconds,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _DotGridPainter(_controller)),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  static const _gap = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(26);
    final shift = animation.value * _gap;
    for (var x = -_gap + shift; x < size.width; x += _gap) {
      for (var y = -_gap + shift; y < size.height; y += _gap) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => false;
}

/// Soft diagonal light band that sweeps across the hero now and then.
class _SheenWidget extends StatelessWidget {
  const _SheenWidget();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bandWidth = constraints.maxWidth * 0.18;
          return ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: double.infinity,
              child:
                  Transform.rotate(
                        angle: 0.35,
                        child: Container(
                          width: bandWidth,
                          height: constraints.maxHeight * 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withAlpha(0),
                                Colors.white.withAlpha(22),
                                Colors.white.withAlpha(0),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .moveX(
                        begin: -bandWidth,
                        end: constraints.maxWidth + bandWidth,
                        duration: 7.seconds,
                        delay: 2.seconds,
                        curve: Curves.easeInOut,
                      ),
            ),
          );
        },
      ),
    );
  }
}

class _WatermarkWidget extends StatelessWidget {
  const _WatermarkWidget({required this.experience, required this.isMobile});

  final ExperienceEntity experience;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final size = context.space(factor: isMobile ? 26 : 44);
    return Positioned(
      right: -size * 0.15,
      bottom: -size * 0.15,
      child: IgnorePointer(
        child:
            Transform.rotate(
                  angle: -0.14,
                  child: Opacity(
                    opacity: 0.1,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.saturation,
                      ),
                      child: DSNetworkImageWidget(
                        url: experience.companyLogo,
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: -6,
                  end: 6,
                  duration: 4.seconds,
                  curve: Curves.easeInOut,
                ),
      ),
    );
  }
}

class _GlowWidget extends StatelessWidget {
  const _GlowWidget({
    required this.color,
    required this.driftX,
    required this.driftY,
  });

  final Color color;
  final double driftX;
  final double driftY;

  @override
  Widget build(BuildContext context) {
    final size = context.space(factor: 30);
    return IgnorePointer(
      child:
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [color.withAlpha(90), color.withAlpha(0)],
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .move(
                begin: Offset.zero,
                end: Offset(driftX, driftY),
                duration: 8.seconds,
                curve: Curves.easeInOut,
              ),
    );
  }
}

/// Circular logo badge with a pulsing halo and a slowly rotating gradient ring.
class _LogoWidget extends StatelessWidget {
  const _LogoWidget({required this.experience, required this.compact});

  final ExperienceEntity experience;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    final secondary = palette.brand.tertiary.color;
    final size = context.space(factor: compact ? 12 : 16);
    const ringThickness = 4.0;
    return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withAlpha(120),
                          blurRadius: 36,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1.08, 1.08),
                    duration: 2.5.seconds,
                    curve: Curves.easeInOut,
                  ),
              Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          accent,
                          secondary,
                          Colors.white.withAlpha(30),
                          accent,
                        ],
                      ),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 8.seconds),
              Hero(
                tag: 'experience-image-${experience.id}',
                child: Container(
                  width: size - ringThickness * 2,
                  height: size - ringThickness * 2,
                  padding: EdgeInsets.all(size * 0.18),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: DSNetworkImageWidget(
                    url: experience.companyLogo,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.6, 0.6),
          duration: 800.ms,
          delay: 200.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 300.ms, delay: 200.ms);
  }
}

class _TitleBlockWidget extends StatelessWidget {
  const _TitleBlockWidget({required this.experience, required this.compact});

  final ExperienceEntity experience;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final url = experience.url;
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(),
          children: [
            if (experience.current)
              _PillWidget(
                icon: Icons.bolt_rounded,
                label: experience.employmentType.toUpperCase(),
                filled: true,
              ),
            DSTextWidget(
              experience.position,
              style: compact
                  ? context.typography.emphasizedHeadlineSmall
                  : context.typography.emphasizedHeadlineLarge,
              color: IntroWidget._onHero,
            ),
            DSTextWidget(
              experience.company,
              style: context.typography.emphasizedTitleMedium,
              color: IntroWidget._onHeroAccent,
            ),
            DSTextWidget(
              experience.description,
              style: context.typography.bodyLarge,
              color: IntroWidget._onHeroMuted,
            ),
            const DSVerticalSpacerWidget(0.25),
            Wrap(
              spacing: context.space(),
              runSpacing: context.space(),
              children: [
                _PillWidget(
                  icon: Icons.location_on_outlined,
                  label: experience.location,
                ),
                _PillWidget(
                  icon: Icons.calendar_today_outlined,
                  label: experience.formattedDateRange(context),
                ),
                if (!experience.current)
                  _PillWidget(
                    icon: Icons.work_outline,
                    label: experience.employmentType,
                  ),
                if (url != null && url.isNotEmpty)
                  _PillWidget(
                    icon: Icons.arrow_outward_rounded,
                    label:
                        Uri.tryParse(url)?.host.replaceFirst('www.', '') ?? url,
                    filled: true,
                    onTap: () => context.bloc.add(
                      OpenExternalUrlEvent(
                        url: url,
                        label: 'Experience Company Website',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        )
        .animate(delay: 300.ms)
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.04, end: 0, duration: 500.ms);
  }
}

class _PillWidget extends StatefulWidget {
  const _PillWidget({
    required this.icon,
    required this.label,
    this.filled = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  State<_PillWidget> createState() => _PillWidgetState();
}

class _PillWidgetState extends State<_PillWidget> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorPalette.brand.primary.color;
    final tappable = widget.onTap != null;
    final active = widget.filled || (tappable && _hover);
    return MouseRegion(
      cursor: tappable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: EdgeInsets.symmetric(
            horizontal: context.space(factor: 1.5),
            vertical: context.space(factor: 0.75),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: active
                ? accent.withAlpha(_hover ? 230 : 170)
                : Colors.white.withAlpha(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: context.space(factor: 0.75),
            children: [
              Icon(widget.icon, size: 16, color: IntroWidget._onHero.color),
              Flexible(
                child: DSTextWidget(
                  widget.label,
                  style: context.typography.emphasizedBodySmall,
                  color: IntroWidget._onHero,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
