part of 'expertise_list_widget.dart';

const _minCoreSkillsCount = 5;

class _MobileContentWidget extends StatelessWidget {
  const _MobileContentWidget({
    required this.allExpertise,
    required this.isVisible,
  });

  final List<ExpertiseEntity> allExpertise;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final mobileList = allExpertise.sublist(0, _minCoreSkillsCount);
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: context.space(factor: 3)),
      itemCount: mobileList.length,
      separatorBuilder: (_, index) => const DSVerticalSpacerWidget(2),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final expertise = mobileList[index];
        return DSExpandableCardWidget(
              headerContent: _MobileHeaderWidget(expertise: expertise),
              expandedContent: _MobileExpandedWidget(expertise: expertise),
            )
            .animate(target: isVisible ? 1 : 0)
            .slideY(
              begin: 1 + (index * 0.2),
              duration: 300.ms,
              delay: (100 + index * 100).ms,
              curve: Curves.easeOut,
            )
            .fadeIn(delay: (300 + index * 100).ms, duration: 300.ms);
      },
    );
  }
}

class _MobileHeaderWidget extends StatelessWidget {
  const _MobileHeaderWidget({required this.expertise});

  final ExpertiseEntity expertise;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.space(factor: 2),
      children: [
        _ImageWidget(imageUrl: expertise.image),
        Expanded(child: _TitleWidget(title: expertise.title, maxLines: 1)),
      ],
    );
  }
}

class _MobileExpandedWidget extends StatelessWidget {
  const _MobileExpandedWidget({required this.expertise});

  final ExpertiseEntity expertise;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(),
      children: [
        DSHorizontalDividerWidget(
          thickness: 1,
          color: context.colorPalette.border,
        ),
        _SkillsWidget(skills: expertise.skills),
      ],
    );
  }
}
