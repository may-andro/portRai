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
          sections: state.scrollableSections,
          tabController: tabController,
        ),
        Expanded(
          child: _BodyWidget(
            scrollController: scrollController,
            sections: state.scrollableSections,
            introSection: state.introSection,
          ),
        ),
        //_FooterWidget(),
      ],
    );
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget({
    required this.introSection,
    required this.scrollController,
    required this.sections,
  });

  final ProjectSectionDTO introSection;
  final List<ScrollableProjectSectionDTO> sections;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 5),
        children: [
          _LeftBodyWidget(introSection: introSection),
          Expanded(
            child: _RightBodyContent(
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
  const _LeftBodyWidget({required this.introSection});

  final ProjectSectionDTO introSection;

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
              child: introSection.buildWidget(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightBodyContent extends StatelessWidget {
  const _RightBodyContent({
    required this.sections,
    required this.scrollController,
  });

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
          padding: EdgeInsets.only(bottom: context.space(factor: 3)),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ...sections.map((section) => section.buildWidget(context)),
            ]),
          ),
        ),
      ],
    );
  }
}
