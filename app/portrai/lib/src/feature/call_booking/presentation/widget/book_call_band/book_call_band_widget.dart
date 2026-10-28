import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/book_call_entry_widget.dart';
import 'package:portrai/src/widget/page_band_widget.dart';

/// A compact, full-width invitation to book a call: an animated calendar, a
/// catchy line and the booking button on a brand gradient. Hosts put it inside
/// a [BookCallEntryWidget] builder and pass on its callback.
class BookCallBandWidget extends StatelessWidget {
  const BookCallBandWidget({
    super.key,
    required this.title,
    required this.description,
    required this.onBookCall,
  });

  final String title;
  final String description;
  final VoidCallback onBookCall;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isDesktop = context.isDesktop;
    final illustration = DSLottieIllustrationWidget(
      illustration: DSLottieIllustration.appointment,
      width: isDesktop ? 120 : 88,
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(),
      children: [
        DSTextWidget(
          title,
          style: isDesktop
              ? context.typography.emphasizedHeadlineMedium
              : context.typography.emphasizedHeadlineSmall,
          color: pageOnDarkColor,
        ),
        DSTextWidget(
          description,
          style: context.typography.bodyLarge,
          color: pageOnDarkColor,
        ),
      ],
    );
    final button = HoverLiftWidget(
      child: DSButtonWidget(
        label: context.localizations.bookCall,
        icon: Icons.arrow_forward_rounded,
        iconDirection: DSButtonIconDirection.right,
        isExpanded: !isDesktop,
        onPressed: onBookCall,
      ),
    );

    return DSOffscreenPauseWidget(
      child: ClipRect(
        child: PageBandWidget(
          verticalFactor: 3,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(palette.brand.primary.color, Colors.black, 0.45)!,
              Color.lerp(palette.brand.tertiary.color, Colors.black, 0.3)!,
            ],
          ),
          background: const _GlowWidget(),
          child: isDesktop
              ? Row(
                  spacing: context.space(factor: 3),
                  children: [
                    illustration,
                    Expanded(child: text),
                    button,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: context.space(factor: 2),
                  children: [
                    Row(
                      spacing: context.space(factor: 2),
                      children: [
                        illustration,
                        Expanded(child: text),
                      ],
                    ),
                    button,
                  ],
                ),
        ),
      ),
    );
  }
}

/// Soft light circles that add depth behind the content.
class _GlowWidget extends StatelessWidget {
  const _GlowWidget();

  @override
  Widget build(BuildContext context) {
    Widget circle(double size, int alpha) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.white.withAlpha(alpha), Colors.white.withAlpha(0)],
        ),
      ),
    );
    return Stack(
      children: [
        Positioned(right: -80, top: -120, child: circle(300, 40)),
        Positioned(left: -60, bottom: -100, child: circle(220, 28)),
      ],
    );
  }
}
