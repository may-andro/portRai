part of 'content_widget.dart';

class _MobileTabletContentWidget extends StatelessWidget {
  const _MobileTabletContentWidget(this.profile);

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 3),
        children: [
          _MobileHeaderWidget(profile: profile),
          _IntroSectionWidget(profile: profile, isDesktop: false),
          _AboutMeSectionWidget(profile: profile, isDesktop: false),
          _SocialLinksSectionWidget(profile: profile, isDesktop: false),
          _ContactSectionWidget(profile: profile, isDesktop: false),
          _AvailabilitySectionWidget(profile: profile, isDesktop: false),
          _EducationSectionWidget(profile: profile, isDesktop: false),
          _LanguageSectionWidget(profile: profile, isDesktop: false),
          FooterWidget(profile: profile),
        ],
      ),
    );
  }
}

class _MobileHeaderWidget extends StatelessWidget {
  const _MobileHeaderWidget({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final coverImageHeight = context.space(factor: 50);
    final descriptionHeight =
        _NameTitleWidget.getHeight(context) + context.space(factor: 2);
    final profileImagenHeight = context.space(factor: 15);
    final blurredContainerHeight = descriptionHeight + profileImagenHeight / 2;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: coverImageHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorPalette.brand.primary.color,
                context.colorPalette.brand.secondary.color,
              ],
            ),
          ),
          child: DSNetworkImageWidget(
            url: profile.coverImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: coverImageHeight,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: blurredContainerHeight,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: descriptionHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colorPalette.surface.surface.color.withValues(
                        alpha: 0.7,
                      ),
                      context.colorPalette.surface.surface.color.withValues(
                        alpha: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: context.space(),
          left: 0,
          right: 0,
          child: _NameTitleWidget(profile: profile),
        ),
        Positioned(
          bottom: blurredContainerHeight - profileImagenHeight / 2,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: profileImagenHeight,
              height: profileImagenHeight,
              child: _ProfileImageWidget(
                url: profile.coverImage,
                //url: profile.profileImage,
              ),
            ),
          ),
        ),
        Positioned(
          top: context.space(factor: 2),
          right: context.space(factor: 2),
          child: DSIconButtonWidget(
            Icons.close,
            iconColor: context.colorPalette.neutral.grey1,
            buttonColor: context.colorPalette.neutral.grey9,
            size: DSIconButtonSize.medium,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
