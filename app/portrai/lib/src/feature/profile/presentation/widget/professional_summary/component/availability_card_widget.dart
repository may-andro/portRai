part of '../professional_summary_widget.dart';

/// Availability, logistics and key numbers for someone deciding to reach out.
class _AvailabilityCardWidget extends StatelessWidget {
  const _AvailabilityCardWidget({
    required this.profile,
    required this.hasHorizontalPadding,
    required this.isVisible,
  });

  final ProfileEntity profile;
  final bool hasHorizontalPadding;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final availability = profile.availability;
    final location = [
      profile.location.city,
      profile.location.country,
    ].where((part) => part.isNotEmpty).join(', ');

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(),
      children: [
        if (availability.status.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: context.space(),
            children: [
              const _StatusDotWidget(),
              Flexible(
                child: DSTextWidget(
                  availability.status,
                  style: context.typography.emphasizedLabelMedium,
                  color: context.colorPalette.surface.onSurface,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        _FactsWidget(
          facts: [
            if (availability.workType.isNotEmpty)
              _Fact(
                icon: Icons.laptop_mac_rounded,
                label: availability.workType,
              ),
            if (location.isNotEmpty)
              _Fact(icon: Icons.place_outlined, label: location),
          ],
          isVisible: isVisible,
          hasHorizontalPadding: false,
        ),
      ],
    );
    final stats = _ProjectYearsWidget(
      isVisible: isVisible,
      animationDelay: 300.ms,
    );

    final accent = context.colorPalette.brand.primary.color;

    return Padding(
      padding: hasHorizontalPadding
          ? context.horizontalScreenPadding
          : EdgeInsets.zero,
      child:
          SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: context.space(factor: 1.5),
                  children: [
                    details,
                    Container(height: 1, color: accent.withAlpha(90)),
                    stats,
                  ],
                ),
              )
              .animate(target: isVisible ? 1 : 0)
              .slideY(
                begin: 0.3,
                duration: 300.ms,
                delay: 150.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 300.ms, delay: 150.ms),
    );
  }
}

class _StatusDotWidget extends StatelessWidget {
  const _StatusDotWidget();

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF2ECC71);

    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 6)],
      ),
    );
  }
}
