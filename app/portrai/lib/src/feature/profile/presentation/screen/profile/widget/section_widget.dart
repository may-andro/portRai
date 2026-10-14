part of 'content_widget.dart';

const _white = DSColor(0xFFFFFFFF);

/// Horizontal inset shared by every band so content lines up down the page.
double _horizontalInset(BuildContext context) {
  if (!context.isDesktop) return context.horizontalScreenPadding.left;
  return context.width * 0.15;
}

/// Full-width page section with its own background.
class _BandWidget extends StatelessWidget {
  const _BandWidget({
    required this.child,
    this.color,
    this.gradient,
    this.background,
    this.verticalFactor = 8,
  });

  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final Widget? background;
  final double verticalFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: color, gradient: gradient),
      child: Stack(
        children: [
          if (background != null) Positioned.fill(child: background!),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _horizontalInset(context),
              vertical: context.space(factor: verticalFactor),
            ),
            child: _RevealWidget(child: child),
          ),
        ],
      ),
    );
  }
}

/// Small spaced-out label with a gradient dash, e.g. "ABOUT ME ——".
class _EyebrowWidget extends StatelessWidget {
  const _EyebrowWidget(this.label, {this.onDark = false});

  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(),
      children: [
        Flexible(
          child: DSTextWidget(
            label.toUpperCase(),
            style: context.typography.emphasizedLabelLarge,
            color: onDark ? _white : palette.neutral.grey7,
          ),
        ),
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: onDark
                  ? [Colors.white54, Colors.white10]
                  : [
                      palette.brand.primary.color,
                      palette.brand.secondary.color,
                    ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DownloadResumeButtonWidget extends StatelessWidget {
  const _DownloadResumeButtonWidget({required this.resumeUrl});

  final String resumeUrl;

  @override
  Widget build(BuildContext context) {
    return _HoverLiftWidget(
      child: DSButtonWidget(
        label: context.localizations.profileDownloadResumeButton,
        icon: Icons.download_rounded,
        variant: DSButtonVariant.secondary,
        isExpanded: false,
        onPressed: () {
          context.bloc.add(
            OpenExternalUrlEvent(url: resumeUrl, label: 'Resume'),
          );
        },
      ),
    );
  }
}

/// Counts a value like "10+" up from zero the first time it appears.
class _CountUpWidget extends StatelessWidget {
  const _CountUpWidget({
    required this.value,
    required this.style,
    required this.color,
  });

  final String value;
  final DSTextStyle style;
  final DSColor color;

  @override
  Widget build(BuildContext context) {
    final target = int.tryParse(value.replaceAll(RegExp(r'\D'), ''));
    if (target == null) {
      return DSTextWidget(value, style: style, color: color);
    }
    final suffix = value.replaceAll(RegExp(r'\d'), '');
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: target),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, count, _) {
        return DSTextWidget('$count$suffix', style: style, color: color);
      },
    );
  }
}
