part of 'content_widget.dart';

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    final onSurface = context.colorPalette.surface.onSurface;
    final primary = context.colorPalette.brand.primary;

    return DSOffscreenPauseWidget(
      child: Column(
        spacing: context.space(),
        children: [
          _FloatingWidget(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.color.withAlpha(90),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: DSCircularLogoWidget(
                size: context.space(factor: context.isMobile ? 8 : 10),
              ),
            ),
          ),
          DSTextWidget(
            context.localizations.onboardingTitle,
            style: context.isMobile
                ? context.typography.emphasizedHeadlineMedium
                : context.typography.emphasizedDisplaySmall,
            color: onSurface,
            textAlign: TextAlign.center,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: DSTextWidget(
              context.localizations.onboardingSubtitle,
              style: context.typography.bodyLarge,
              color: context.colorPalette.surface.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),
    );
  }
}

/// Bobs its child up and down, skipped when the platform asks for reduced
/// motion.
class _FloatingWidget extends StatelessWidget {
  const _FloatingWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(
          begin: -4,
          end: 4,
          duration: 2500.ms,
          curve: Curves.easeInOutSine,
        );
  }
}
