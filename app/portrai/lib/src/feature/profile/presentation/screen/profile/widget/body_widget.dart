part of 'content_widget.dart';

class _BodyWidget extends StatelessWidget {
  const _BodyWidget({required this.profile, required this.workPlaces});

  final ProfileEntity profile;
  final List<WorkPlaceEntity> workPlaces;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    return CustomScrollView(
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false, overscroll: false),
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (isDesktop)
          const SliverToBoxAdapter(child: _HeaderWidget())
        else
          _AppBarWidget(title: profile.fullName),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroWidget(profile: profile, isDesktop: isDesktop),
              _GlobalBandWidget(
                profile: profile,
                workPlaces: workPlaces,
                isDesktop: isDesktop,
              ),
              _AboutBandWidget(profile: profile, isDesktop: isDesktop),
              _BackgroundBandWidget(profile: profile, isDesktop: isDesktop),
              _ContactBandWidget(profile: profile, isDesktop: isDesktop),
              FooterWidget(profile: profile),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppBarWidget extends StatelessWidget {
  const _AppBarWidget({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: context.dimen.elevationNone.value,
      scrolledUnderElevation: context.dimen.elevationNone.value,
      backgroundColor: context.colorPalette.background.color,
      surfaceTintColor: context.colorPalette.neutral.transparent.color,
      foregroundColor: context.colorPalette.surface.onInverseSurface.color,
      automaticallyImplyLeading: !kIsWeb,
      centerTitle: true,
      title: DSTextWidget(
        title,
        color: context.colorPalette.neutral.grey9,
        style: kIsWeb
            ? context.typography.emphasizedTitleLarge
            : context.typography.emphasizedTitleMedium,
      ),
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.space(factor: 7),
      padding: EdgeInsets.symmetric(horizontal: context.space(factor: 2)),
      child: Row(
        children: [
          Flexible(
            child: Image.asset(
              DSImage.logoPath,
              package: 'design_system',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
