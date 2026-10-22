part of 'content_widget.dart';

class _PersistentTabBarDelegate extends SliverPersistentHeaderDelegate {
  _PersistentTabBarDelegate({
    required this.sections,
    required this.tabController,
    required this.height,
  });

  final List<ScrollableSectionWidget> sections;
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
  final List<ScrollableSectionWidget> sections;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return AnimatedContainer(
      duration: 200.ms,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: palette.background.color.withAlpha(overlapsContent ? 245 : 255),
      ),
      // Painted on top so the 1px line doesn't take up layout space.
      foregroundDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: overlapsContent
                ? palette.neutral.grey3.color
                : Colors.transparent,
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: _TabBarWidget(sections: sections, tabController: tabController),
      ),
    );
  }
}

class _TabBarWidget extends StatelessWidget {
  const _TabBarWidget({required this.sections, required this.tabController});

  final List<ScrollableSectionWidget> sections;
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
          padding: EdgeInsets.only(left: context.screenHorizontalPadding.left),
          tabAlignment: TabAlignment.start,
          tabs: sections
              .map(
                (section) => DSTabItemWidget(
                  title: section.getTitle(context),
                  onTap: () {
                    tabController.animateTo(sections.indexOf(section));
                    final keyContext = section.sectionKey.currentContext;
                    if (keyContext == null) return;
                    Scrollable.ensureVisible(
                      keyContext,
                      duration: 400.ms,
                      curve: Curves.easeInOut,
                    );
                    context.bloc.add(HeaderTabClickEvent(section.trackingId));
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
