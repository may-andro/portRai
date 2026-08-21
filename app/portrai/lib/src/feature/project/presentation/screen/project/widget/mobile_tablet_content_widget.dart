part of 'content_widget.dart';

class _MobileTabletContentWidget extends StatelessWidget {
  const _MobileTabletContentWidget({
    required this.tabController,
    required this.scrollController,
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
      shrinkWrap: true,
      slivers: [
        _AppBarWidget(title: state.project.title),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: context.space(factor: 3),
            horizontal: context.horizontalPadding,
          ),
          sliver: SliverToBoxAdapter(
            child: state.introSection.buildWidget(context),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PersistentTabBarDelegate(
            sections: state.scrollableSections,
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
            delegate: SliverChildListDelegate([
              ...state.scrollableSections.map(
                (section) => section.buildWidget(context),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
