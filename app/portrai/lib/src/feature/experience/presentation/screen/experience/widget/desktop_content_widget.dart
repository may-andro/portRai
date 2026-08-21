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
      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false, overscroll: false),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _HeaderWidget(
            sections: scrollableSections,
            tabController: tabController,
          ),
        ),
        SliverToBoxAdapter(
          child: _BodyWidget(
            experience: experience,
            scrollController: scrollController,
            sections: scrollableSections,
          ),
        ),
        if (state.profile case final ProfileEntity profile)
          SliverToBoxAdapter(child: FooterWidget(profile: profile)),
      ],
    );
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget({
    required this.experience,
    required this.scrollController,
    required this.sections,
  });

  final ExperienceEntity experience;
  final List<ScrollableSectionWidget> sections;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 5),
        children: [
          _LeftBodyWidget(experience: experience),
          Expanded(
            child: _RightBodyWidget(
              sections: sections,
              scrollController: scrollController,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftBodyWidget extends StatelessWidget {
  const _LeftBodyWidget({required this.experience});

  final ExperienceEntity experience;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.space(factor: 20),
      child: CustomScrollView(
        scrollBehavior: ScrollConfiguration.of(
          context,
        ).copyWith(scrollbars: false, overscroll: false),
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(bottom: context.space(factor: 3)),
            sliver: SliverToBoxAdapter(
              child: IntroSectionWidget(experience: experience),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightBodyWidget extends StatelessWidget {
  const _RightBodyWidget({
    required this.sections,
    required this.scrollController,
  });

  final List<ScrollableSectionWidget> sections;
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
          padding: EdgeInsets.only(bottom: context.space(factor: 3)),
          sliver: SliverList(delegate: SliverChildListDelegate(sections)),
        ),
      ],
    );
  }
}
