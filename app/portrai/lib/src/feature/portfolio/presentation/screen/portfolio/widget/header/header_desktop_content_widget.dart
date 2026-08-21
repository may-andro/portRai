part of 'header_widget.dart';

class _HeaderDesktopContentWidget extends StatelessWidget {
  const _HeaderDesktopContentWidget({
    required this.sections,
    required this.tabController,
  });

  final List<SectionWidget> sections;
  final TabController tabController;

  static double getHeight(BuildContext context) {
    return context.space(factor: 7);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(context),
      padding: EdgeInsets.symmetric(horizontal: context.space(factor: 2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            DSImage.logoPath,
            package: 'design_system',
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: DSTabItemWidget.getHeight(context),
            child: _TabBarWidget(
              sections: sections,
              tabController: tabController,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarWidget extends StatelessWidget {
  const _TabBarWidget({required this.sections, required this.tabController});

  final List<SectionWidget> sections;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return BlocBuilder<PortfolioBloc, PortfolioState>(
          builder: (context, state) {
            final selectedSectionIndex = switch (state) {
              LoadedState(:final selectedSectionIndex) => selectedSectionIndex,
              _ => 0,
            };

            return TabBar(
              controller: tabController,
              isScrollable: true,
              indicator: const BoxDecoration(),
              indicatorColor: Colors.transparent,
              indicatorWeight: 0,
              dividerColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              labelPadding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
              tabs: sections.map((section) {
                final index = sections.indexOf(section);
                return DSTabItemWidget(
                  title: section.getTitle(context),
                  isSelected: selectedSectionIndex == index,
                  isIndicatorEnabled: true,
                  onTap: () {
                    context.bloc.add(
                      SectionNavigationEvent(
                        sectionIndex: index,
                        sectionId: section.trackingId,
                        source: NavigationSource.header,
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
