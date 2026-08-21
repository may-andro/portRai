part of 'content_widget.dart';

class _DesktopContentWidget extends StatelessWidget {
  const _DesktopContentWidget(this.profile);

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: context.space(factor: 4),
        children: [
          _DesktopHeaderWidget(profile: profile),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: context.width * 0.15,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(factor: 5),
              children: [
                _LeftBodyWidget(profile: profile),
                Expanded(child: _RightBodyWidget(profile: profile)),
              ],
            ),
          ),
          FooterWidget(profile: profile),
        ],
      ),
    );
  }
}

class _DesktopHeaderWidget extends StatelessWidget {
  const _DesktopHeaderWidget({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final coverImageHeight = context.space(factor: 30);
    final descriptionHeight =
        _NameTitleWidget.getHeight(context) + context.space(factor: 2);
    final profileImagenHeight = context.space(factor: 10);
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
          height: descriptionHeight,
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
          left:
              context.width * 0.15 +
              profileImagenHeight +
              context.space(factor: 2),
          child: _NameTitleWidget(
            profile: profile,
            alignment: CrossAxisAlignment.start,
          ),
        ),
        Positioned(
          bottom: descriptionHeight - profileImagenHeight / 2,
          left: context.width * 0.15,
          child: _ProfileImageWidget(url: profile.profileImage),
        ),
        Positioned(
          bottom: descriptionHeight - DSButtonSize.large.height / 2,
          right: context.width * 0.15,
          child: _DownloadResumeButtonWidget(resumeUrl: profile.resume.url),
        ),
      ],
    );
  }
}

class _LeftBodyWidget extends StatelessWidget {
  const _LeftBodyWidget({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.space(factor: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 3),
        children: [
          _ContactSectionWidget(profile: profile, isDesktop: true),
          _AvailabilitySectionWidget(profile: profile, isDesktop: true),
          _LanguageSectionWidget(profile: profile, isDesktop: true),
        ],
      ),
    );
  }
}

class _RightBodyWidget extends StatelessWidget {
  const _RightBodyWidget({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.space(factor: 3),
      children: [
        _IntroSectionWidget(profile: profile, isDesktop: true),
        _AboutMeSectionWidget(profile: profile, isDesktop: true),
        _SocialLinksSectionWidget(profile: profile, isDesktop: true),
        _EducationSectionWidget(profile: profile, isDesktop: true),
      ],
    );
  }
}
