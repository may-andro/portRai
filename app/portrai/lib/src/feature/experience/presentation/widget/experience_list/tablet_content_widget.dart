part of 'experience_list_widget.dart';

class _TabletContentWidget extends StatelessWidget {
  const _TabletContentWidget({
    required this.experiences,
    required this.isVisible,
  });

  final List<ExperienceEntity> experiences;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: context.space(),
        mainAxisSpacing: context.space(),
        mainAxisExtent: _TabletItemWidget.getHeight(context),
      ),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        final experience = experiences[index];
        return _TabletItemWidget(experience: experience)
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

class _TabletItemWidget extends StatelessWidget {
  const _TabletItemWidget({required this.experience});

  final ExperienceEntity experience;

  static double getHeight(BuildContext context) {
    final imageSize = context.space(factor: 7);
    final titlePositionHeight = _TitlePositionWidget.getHeight(context);
    final additionalInfoHeight = _AdditionalInfoWidget.getHeight(context);
    final verticalPadding = context.space(factor: 2) * 2;
    final spacing = context.space() * 2;
    return imageSize +
        titlePositionHeight +
        additionalInfoHeight +
        verticalPadding +
        spacing;
  }

  @override
  Widget build(BuildContext context) {
    return DSCardWidget(
      elevation: context.dimen.elevationLevel1,
      backgroundColor: context.colorPalette.surface.surfaceContainerHighest,
      radius: context.dimen.radiusLevel1,
      onTap: () {
        ExperienceScreen.navigate(context, id: experience.id);
      },
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 2)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: context.space(),
          children: [
            _ImageWidget(
              experience: experience,
              size: context.space(factor: 7),
            ),
            _TitlePositionWidget(
              experience: experience,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            _AdditionalInfoWidget(experience: experience),
          ],
        ),
      ),
    );
  }
}

class _AdditionalInfoWidget extends StatelessWidget {
  const _AdditionalInfoWidget({required this.experience});

  final ExperienceEntity experience;

  static double getHeight(BuildContext context) {
    final leftHeight = _DateLocationWidget.getHeight(context);
    final rightHeight = DSIconSize.large.getSize(context);
    return max(leftHeight, rightHeight);
  }

  @override
  Widget build(BuildContext context) {
    final right = DSIconWidget(
      Icons.arrow_right_rounded,
      color: context.colorPalette.surface.onSurface,
      size: DSIconSize.large,
    );

    return Row(
      children: [
        Expanded(child: _DateLocationWidget(experience: experience)),
        const DSHorizontalSpacerWidget(0.2),
        right,
      ],
    );
  }
}
