part of 'personal_summary_widget.dart';

class _DetailsWidget extends StatelessWidget {
  const _DetailsWidget({
    required this.profile,
    required this.isVisible,
    required this.isCentered,
  });

  final ProfileEntity profile;
  final bool isVisible;
  final bool isCentered;

  @override
  Widget build(BuildContext context) {
    final onSurface = context.colorPalette.surface.onInverseSurface;
    final alignment = isCentered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = isCentered ? TextAlign.center : TextAlign.start;
    final education = profile.educations.firstOrNull;

    return Column(
          crossAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: 2),
          children: [
            _HoverLiftWidget(
              child: DSAvailabilityBadgeWidget(
                label:
                    '${context.localizations.profileAvailableForWork} · ${profile.availability.workType}',
                color: Colors.greenAccent.shade400,
                textColor: onSurface,
              ),
            ),
            DSTextWidget(
              profile.fullName,
              style: context.typography.emphasizedDisplaySmall,
              color: onSurface,
              textAlign: textAlign,
            ),
            _AccentBarWidget(isCentered: isCentered),
            DSTextWidget(
              profile.subtitle,
              style: context.typography.emphasizedTitleMedium,
              color: context.colorPalette.accent,
              textAlign: textAlign,
            ),
            Wrap(
              alignment: isCentered
                  ? WrapAlignment.center
                  : WrapAlignment.start,
              spacing: context.space(factor: 1.5),
              runSpacing: context.space(factor: 1.5),
              children: [
                _HoverLiftWidget(
                  child: DSIconInfoTileWidget(
                    icon: Icons.location_on_rounded,
                    iconWidget: const DSLottieIllustrationWidget(
                      illustration: DSLottieIllustration.mapPin,
                      width: 40,
                    ),
                    label: context.localizations.profileLocation,
                    value:
                        '${profile.location.city}, ${profile.location.country}',
                    startColor: context.colorPalette.brand.primary,
                    endColor: context.colorPalette.brand.tertiary,
                    textColor: onSurface,
                  ),
                ),
                if (education != null)
                  _HoverLiftWidget(
                    child: DSIconInfoTileWidget(
                      icon: Icons.school_rounded,
                      iconWidget: const DSLottieIllustrationWidget(
                        illustration: DSLottieIllustration.graduationHat,
                        width: 40,
                      ),
                      label: context.localizations.profileEducation,
                      value: education.degree,
                      startColor: context.colorPalette.brand.primary,
                      endColor: context.colorPalette.brand.tertiary,
                      textColor: onSurface,
                    ),
                  ),
              ],
            ),
            Wrap(
              alignment: isCentered
                  ? WrapAlignment.center
                  : WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: context.space(),
              runSpacing: context.space(),
              children: [
                for (final language in profile.languages)
                  _HoverLiftWidget(
                    child: DSInfoChipWidget(
                      icon: Icons.translate_rounded,
                      label: language.language,
                    ),
                  ),
                _HoverLiftWidget(
                  scale: 1.12,
                  child: Tooltip(
                    message: context.localizations.profileViewFullProfile,
                    child: DSIconButtonWidget(
                      Icons.arrow_outward_rounded,
                      iconColor: context.colorPalette.brand.onPrimary,
                      buttonColor: context.colorPalette.brand.primary,
                      size: context.buttonSize,
                      elevation: context.dimen.elevationLevel2,
                      onPressed: () => ProfileScreen.navigate(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
        .animate(target: isVisible ? 1 : 0)
        .slideX(
          begin: isCentered ? 0 : -0.1,
          duration: 500.ms,
          delay: 200.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(delay: 200.ms, duration: 500.ms);
  }
}

class _AccentBarWidget extends StatelessWidget {
  const _AccentBarWidget({required this.isCentered});

  final bool isCentered;

  @override
  Widget build(BuildContext context) {
    return DSHoverableContainerWidget(
      builder: (context, isHovering) {
        return AnimatedContainer(
          duration: 250.ms,
          curve: Curves.easeOut,
          width: context.space(factor: isHovering ? 14 : 8),
          height: 4,
          decoration: BoxDecoration(
            color: context.colorPalette.accent.color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}

class _HoverLiftWidget extends StatelessWidget {
  const _HoverLiftWidget({required this.child, this.scale = 1.06});

  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return DSHoverableContainerWidget(
      builder: (context, isHovering) {
        return AnimatedSlide(
          duration: 200.ms,
          curve: Curves.easeOutBack,
          offset: Offset(0, isHovering ? -0.08 : 0),
          child: AnimatedScale(
            duration: 200.ms,
            curve: Curves.easeOutBack,
            scale: isHovering ? scale : 1,
            child: child,
          ),
        );
      },
    );
  }
}

extension on BuildContext {
  DSIconButtonSize get buttonSize {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return DSIconButtonSize.large;
      case DSDeviceResolution.tablet:
        return DSIconButtonSize.medium;
      case DSDeviceResolution.desktop:
        return DSIconButtonSize.small;
    }
  }
}
