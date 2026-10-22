part of 'content_widget.dart';

class _BodyWidget extends StatelessWidget {
  const _BodyWidget({
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

    return CustomScrollView(
      controller: scrollController,
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false, overscroll: false),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: state.introSection.buildWidget(context)),
        SliverToBoxAdapter(child: MetricsWidget(project: state.project)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PersistentTabBarDelegate(
            sections: state.scrollableSections,
            tabController: tabController,
            height: DSTabItemWidget.getHeight(context),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              for (final section in state.scrollableSections)
                section.buildWidget(context),
            ],
          ),
        ),
        if (state.profile case final ProfileEntity profile)
          SliverToBoxAdapter(child: FooterWidget(profile: profile)),
      ],
    );
  }
}
