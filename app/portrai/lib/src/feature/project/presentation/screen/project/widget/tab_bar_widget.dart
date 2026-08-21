part of 'content_widget.dart';

class _PersistentTabBarDelegate extends SliverPersistentHeaderDelegate {
  _PersistentTabBarDelegate({
    required this.sections,
    required this.tabController,
    required this.height,
  });

  final List<ScrollableProjectSectionDTO> sections;
  final TabController tabController;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _PersistentTabBarHeaderWidget(
      overlapsContent: overlapsContent,
      sections: sections,
      tabController: tabController,
    );
  }

  @override
  bool shouldRebuild(covariant _PersistentTabBarDelegate oldDelegate) {
    return maxExtent != oldDelegate.maxExtent ||
        minExtent != oldDelegate.minExtent;
  }
}

class _PersistentTabBarHeaderWidget extends StatelessWidget {
  const _PersistentTabBarHeaderWidget({
    required this.overlapsContent,
    required this.sections,
    required this.tabController,
  });

  final bool overlapsContent;
  final List<ScrollableProjectSectionDTO> sections;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: overlapsContent ? context.dimen.elevationLevel3.value : 0.0,
      ),
      duration: 200.ms,
      curve: Curves.easeOut,
      builder: (context, elevation, child) {
        return Material(
          color: context.colorPalette.background.color,
          elevation: elevation,
          shadowColor: context.colorPalette.brand.tertiary.color,
          child: child,
        );
      },
      child: _TabBarWidget(sections: sections, tabController: tabController),
    );
  }
}

class _TabBarWidget extends StatelessWidget {
  const _TabBarWidget({required this.sections, required this.tabController});

  final List<ScrollableProjectSectionDTO> sections;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return TabBar(
          controller: tabController,
          isScrollable: true,
          indicator: const BoxDecoration(),
          indicatorColor: Colors.transparent,
          indicatorWeight: 0,
          dividerColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelPadding: EdgeInsets.zero,
          padding: context.isDesktop
              ? EdgeInsets.zero
              : EdgeInsets.only(left: context.horizontalPadding),
          tabAlignment: TabAlignment.start,
          tabs: sections
              .map(
                (section) => DSTabItemWidget(
                  title: section.getTitle(context),
                  onTap: () {
                    tabController.animateTo(sections.indexOf(section));
                    final key = section.sectionKey;
                    final currentContext = key.currentContext;
                    if (currentContext == null) return;
                    Scrollable.ensureVisible(
                      currentContext,
                      duration: 400.ms,
                      curve: Curves.easeInOut,
                    );
                    context.bloc.add(HeaderTabClickEvent(section));
                  },
                  isSelected: sections[tabController.index] == section,
                  isIndicatorEnabled: true,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
