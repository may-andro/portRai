part of 'content_widget.dart';

class _SocialLinksSectionWidget extends StatelessWidget {
  const _SocialLinksSectionWidget({
    required this.profile,
    required this.isDesktop,
  });

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return _SectionWidget(
      label: 'Connect With Me',
      isDesktop: isDesktop,
      children: [
        Wrap(
          spacing: context.space(factor: 2),
          runSpacing: context.space(factor: 2),
          children: profile.socialLinks.map((socialLink) {
            return _SocialLinkChip(socialLink: socialLink);
          }).toList(),
        ),
      ],
    );
  }
}

class _SocialLinkChip extends StatelessWidget {
  const _SocialLinkChip({required this.socialLink});

  final SocialLinkEntity socialLink;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.bloc.add(
          OpenExternalUrlEvent(url: socialLink.url, label: socialLink.name),
        );
      },
      borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 2),
          vertical: context.space(factor: 1.5),
        ),
        decoration: BoxDecoration(
          color: context.colorPalette.surface.surfaceContainerHighest.color,
          borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
          border: Border.all(
            color: context.colorPalette.brand.secondary.color.withAlpha(100),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(),
          children: [
            DSNetworkImageWidget(
              url: socialLink.image,
              width: 24,
              height: 24,
              color: context.colorPalette.brand.secondary,
            ),
            DSTextWidget(
              socialLink.name,
              style: context.typography.emphasizedBodyMedium,
              color: context.colorPalette.neutral.grey9,
            ),
          ],
        ),
      ),
    );
  }
}
