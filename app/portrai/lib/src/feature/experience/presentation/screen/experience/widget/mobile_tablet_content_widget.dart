part of 'content_widget.dart';

class _MobileTabletContentWidget extends StatelessWidget {
  const _MobileTabletContentWidget({
    required this.experience,
    required this.scrollableSections,
    required this.tabController,
    required this.scrollController,
  });

  final ExperienceEntity experience;
  final List<ScrollableSectionWidget> scrollableSections;
  final ScrollController scrollController;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    if (state is! LoadedState) {
      return const SizedBox.shrink();
    }

    return CustomScrollView(
      controller: scrollController,
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false, overscroll: false),
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      slivers: [
        _AppBarWidget(title: state.experience.company),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: context.space(factor: 3),
            horizontal: context.horizontalPadding,
          ),
          sliver: SliverToBoxAdapter(
            child: IntroSectionWidget(experience: experience),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PersistentTabBarDelegate(
            sections: scrollableSections,
            tabController: tabController,
            height: DSTabItemWidget.getHeight(context),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: context.space(factor: 3),
            horizontal: context.horizontalPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(scrollableSections),
          ),
        ),
        if (state.profile case final ProfileEntity profile)
          SliverPadding(
            padding: EdgeInsets.only(top: context.space(factor: 3)),
            sliver: SliverToBoxAdapter(child: FooterWidget(profile: profile)),
          ),
      ],
    );
  }
}
