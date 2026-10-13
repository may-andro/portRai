import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/extension/experience_date_range_extension.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';

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
    final radius = BorderRadius.circular(
      context.dimen.radiusLevel3.value * 1.5,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // Judge by the card's own width, not the device, so it never gets squeezed.
        final isMobile = constraints.maxWidth < 760;
        return _buildCard(context, isMobile, radius, start, end);
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    bool isMobile,
    BorderRadius radius,
    Color start,
    Color end,
  ) {
    final palette = context.colorPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.brand.primary.color.withAlpha(50),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned(
              right: -context.space(factor: 10),
              top: -context.space(factor: 10),
              child: _GlowWidget(color: palette.brand.primary.color),
            ),
            Positioned(
              left: -context.space(factor: 12),
              bottom: -context.space(factor: 12),
              child: _GlowWidget(color: palette.brand.tertiary.color),
            ),
            Positioned.fill(child: _PatternWidget()),
            _WatermarkWidget(experience: experience, isMobile: isMobile),
            Padding(
              padding: EdgeInsets.all(context.space(factor: isMobile ? 3 : 5)),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: context.space(factor: 2.5),
                      children: [
                        _LogoWidget(experience: experience, compact: isMobile),
                        _TitleBlockWidget(
                          experience: experience,
                          compact: isMobile,
                        ),
                        _StatsWidget(experience: experience),
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
                        _StatsWidget(experience: experience),
                      ],
                    ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.06, end: 0);
  }
}

class _PatternWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _DotGridPainter()));
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(22);
    const gap = 22.0;
    for (var x = gap / 2; x < size.width; x += gap) {
      for (var y = gap / 2; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  const _GlowWidget({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = context.space(factor: 30);
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withAlpha(90), color.withAlpha(0)],
          ),
        ),
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget({required this.experience, required this.compact});

  final ExperienceEntity experience;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = context.space(factor: compact ? 11 : 14);
    return Hero(
          tag: 'experience-image-${experience.id}',
          child: Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(size * 0.14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size * 0.24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: DSNetworkImageWidget(
              url: experience.companyLogo,
              fit: BoxFit.contain,
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.7, 0.7),
          duration: 700.ms,
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

class _StatsWidget extends StatelessWidget {
  const _StatsWidget({required this.experience});

  final ExperienceEntity experience;

  String _duration() {
    final end = experience.endDate ?? DateTime.now();
    final start = experience.startDate;
    final months = ((end.year - start.year) * 12 + end.month - start.month + 1)
        .clamp(1, 1200);
    final years = months ~/ 12;
    final rest = months % 12;
    if (years == 0) return '${rest}m';
    return rest == 0 ? '${years}y' : '${years}y ${rest}m';
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('Duration', _duration()),
      ('Technologies', '${experience.technologies.length}'),
      ('Achievements', '${experience.achievements.length}'),
    ];
    return Row(
      spacing: context.space(),
      children: [
        for (final (index, stat) in stats.indexed)
          Expanded(
            child:
                Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.space(factor: 1.5),
                        horizontal: context.space(),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          context.dimen.radiusLevel2.value,
                        ),
                        color: Colors.white.withAlpha(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        spacing: context.space(factor: 0.25),
                        children: [
                          FittedBox(
                            child: DSTextWidget(
                              stat.$2,
                              style: context.typography.emphasizedHeadlineSmall,
                              color: IntroWidget._onHero,
                            ),
                          ),
                          DSTextWidget(
                            stat.$1,
                            style: context.typography.bodySmall,
                            color: IntroWidget._onHeroMuted,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    )
                    .animate(delay: (500 + index * 120).ms)
                    .fadeIn()
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
          ),
      ],
    );
  }
}
