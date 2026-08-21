part of 'content_widget.dart';

class _AvailabilitySectionWidget extends StatelessWidget {
  const _AvailabilitySectionWidget({
    required this.profile,
    required this.isDesktop,
  });

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.horizontalScreenPadding,
      child: DSCardWidget(
        elevation: context.dimen.elevationLevel1,
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(factor: 1.5),
            children: [
              Row(
                children: [
                  Icon(
                    Icons.work_outline_rounded,
                    color: context.colorPalette.brand.primary.color,
                    size: context.getTextHeight(
                      context.typography.emphasizedTitleMedium,
                      1,
                    ),
                  ),
                  DSHorizontalSpacerWidget(isDesktop ? 0.75 : 1),
                  Expanded(
                    child: DSTextWidget(
                      'Current Role',
                      style: context.typography.emphasizedTitleMedium,
                      color: context.colorPalette.neutral.grey10,
                    ),
                  ),
                ],
              ),
              DSTextWidget(
                profile.currentRole,
                style: isDesktop
                    ? context.typography.emphasizedBodyMedium
                    : context.typography.emphasizedBodyLarge,
                color: context.colorPalette.neutral.grey9,
                maxLines: isDesktop ? 2 : null,
              ),
              DSTextWidget(
                profile.currentCompany,
                style: isDesktop
                    ? context.typography.bodySmall
                    : context.typography.bodyMedium,
                color: context.colorPalette.neutral.grey8,
                maxLines: isDesktop ? 2 : null,
              ),
              DSHorizontalDividerWidget(
                thickness: 1,
                color: context.colorPalette.neutral.grey5,
              ),
              Container(
                padding: EdgeInsets.all(
                  context.space(factor: isDesktop ? 1.25 : 1.5),
                ),
                decoration: BoxDecoration(
                  color: context.colorPalette.brand.secondaryContainer.color,
                  borderRadius: BorderRadius.circular(
                    context.dimen.radiusLevel1.value,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: context.colorPalette.brand.secondary.color,
                      size: (isDesktop ? DSIconSize.small : DSIconSize.medium)
                          .getSize(context),
                    ),
                    DSHorizontalSpacerWidget(isDesktop ? 0.75 : 1),
                    Expanded(
                      child: DSTextWidget(
                        profile.availability.status,
                        style: isDesktop
                            ? context.typography.emphasizedBodySmall
                            : context.typography.emphasizedBodyMedium,
                        color: context.colorPalette.neutral.grey9,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
