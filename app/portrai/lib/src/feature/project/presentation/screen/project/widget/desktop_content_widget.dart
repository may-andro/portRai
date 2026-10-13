part of 'content_widget.dart';

class _DesktopContentWidget extends StatelessWidget {
  const _DesktopContentWidget({
    required this.scrollController,
    required this.tabController,
  });

  final ScrollController scrollController;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final state = context.state;
    if (state is! LoadedState) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _HeaderWidget(
          sections: state.scrollableSections
              .where((s) => s is! AvailabilitiesSectionDTO)
              .toList(),
          tabController: tabController,
        ),
        Expanded(
          child: _BodyWidget(
            scrollController: scrollController,
            sections: state.scrollableSections,
            project: state.project,
            profile: state.profile,
          ),
        ),
        //_FooterWidget(),
      ],
    );
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget({
    required this.project,
    required this.profile,
    required this.scrollController,
    required this.sections,
  });

  final ProjectEntity project;
  final ProfileEntity? profile;
  final List<ScrollableProjectSectionDTO> sections;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false, overscroll: false),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            context.horizontalPadding,
            0,
            context.horizontalPadding,
            context.space(factor: 3),
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(factor: 5),
              children: [
                SizedBox(
                  width: context.space(factor: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: context.space(factor: 4),
                    children: [
                      IntroWidget(project: project, sidebar: true),
                      ...sections.whereType<AvailabilitiesSectionDTO>().map(
                        (section) => section.buildWidget(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: context.space(factor: 4),
                    children: [
                      ...sections
                          .where((s) => s is! AvailabilitiesSectionDTO)
                          .map((section) => section.buildWidget(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (profile case final ProfileEntity profile)
          SliverToBoxAdapter(child: FooterWidget(profile: profile)),
      ],
    );
  }
}
