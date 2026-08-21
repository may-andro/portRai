part of 'content_widget.dart';

class _IntroSectionWidget extends StatelessWidget {
  const _IntroSectionWidget({required this.profile, required this.isDesktop});

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.horizontalScreenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 2),
        children: [
          _UniqueValueProposition(
            uniqueValueProposition: profile.uniqueValueProposition,
          ),
          if (!isDesktop) ...[
            _DownloadResumeButtonWidget(resumeUrl: profile.resume.url),
          ],
          Row(
            spacing: context.space(factor: 2),
            children: [
              Expanded(
                child: _StatsCard(
                  icon: Icons.work_rounded,
                  value: '${profile.yearsOfExperience}+',
                  label: 'Years Experience',
                  color: context.colorPalette.brand.primary.color,
                ),
              ),
              Expanded(
                child: _StatsCard(
                  icon: Icons.apps_rounded,
                  value: '${profile.projectsDelivered}+',
                  label: 'Projects',
                  color: context.colorPalette.brand.secondary.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DownloadResumeButtonWidget extends StatelessWidget {
  const _DownloadResumeButtonWidget({required this.resumeUrl});

  final String resumeUrl;

  @override
  Widget build(BuildContext context) {
    return DSButtonWidget(
      label: 'Download Resume',
      icon: Icons.download_rounded,
      border: DSButtonBorder.rounded,
      onPressed: () {
        context.bloc.add(OpenExternalUrlEvent(url: resumeUrl, label: 'Resume'));
      },
    );
  }
}

class _UniqueValueProposition extends StatelessWidget {
  const _UniqueValueProposition({required this.uniqueValueProposition});

  final String uniqueValueProposition;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 2.5),
        vertical: context.space(factor: 1.5),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colorPalette.brand.primaryContainer.color,
            context.colorPalette.brand.secondaryContainer.color,
          ],
        ),
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
        border: Border.all(
          color: context.colorPalette.brand.primary.color.withAlpha(50),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: context.space(factor: 1.5),
        children: [
          Icon(
            Icons.verified_rounded,
            color: context.colorPalette.brand.primary.color,
            size: context.getTextHeight(
              context.typography.emphasizedBodyMedium,
              1,
            ),
          ),
          Flexible(
            child: DSTextWidget(
              uniqueValueProposition,
              style: context.typography.emphasizedBodyMedium,
              color: context.colorPalette.neutral.grey10,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(30), color.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        border: Border.all(color: color.withAlpha(100), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(30),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 2.5)),
        child: Column(
          spacing: context.space(factor: 1.5),
          children: [
            Container(
              padding: EdgeInsets.all(context.space(factor: 1.5)),
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            DSTextWidget(
              value,
              style: context.typography.emphasizedHeadlineMedium,
              color: context.colorPalette.neutral.grey10,
            ),
            DSTextWidget(
              label,
              style: context.typography.emphasizedBodySmall,
              color: context.colorPalette.neutral.grey8,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
