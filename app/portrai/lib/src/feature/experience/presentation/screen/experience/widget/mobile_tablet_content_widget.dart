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
        SliverToBoxAdapter(child: IntroSectionWidget(experience: experience)),
        SliverToBoxAdapter(
          child: KeyFactsSectionWidget(experience: experience),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PersistentTabBarDelegate(
            sections: scrollableSections,
            tabController: tabController,
            height: DSTabItemWidget.getHeight(context),
          ),
        ),
        SliverToBoxAdapter(
          child: _SectionListWidget(scrollableSections: scrollableSections),
        ),
        if (state.profile case final ProfileEntity profile)
          SliverToBoxAdapter(child: FooterWidget(profile: profile)),
      ],
    );
  }
}
