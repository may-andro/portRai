part of 'content_widget.dart';

class _DesktopContentWidget extends StatelessWidget {
  const _DesktopContentWidget({
    required this.experience,
    required this.scrollableSections,
    required this.scrollController,
    required this.tabController,
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
      slivers: [
        PageAppBarWidget(title: state.experience.company),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: context.space(factor: 2),
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
            horizontal: context.horizontalPadding,
            vertical: context.space(factor: 4),
          ),
          sliver: SliverToBoxAdapter(
            child: _SectionGridWidget(sections: scrollableSections),
          ),
        ),
        if (state.profile case final ProfileEntity profile)
          SliverToBoxAdapter(child: FooterWidget(profile: profile)),
      ],
    );
  }
}

/// Lays the sections out in a two-column masonry-like grid on wide screens.
class _SectionGridWidget extends StatelessWidget {
  const _SectionGridWidget({required this.sections});

  final List<ScrollableSectionWidget> sections;

  @override
  Widget build(BuildContext context) {
    final gap = context.space(factor: 3);
    final left = <Widget>[];
    final right = <Widget>[];
    for (final (index, section) in sections.indexed) {
      (index.isEven ? left : right).add(section);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: gap,
      children: [
        Expanded(
          child: Column(spacing: gap, children: left),
        ),
        Expanded(
          child: Column(spacing: gap, children: right),
        ),
      ],
    );
  }
}
