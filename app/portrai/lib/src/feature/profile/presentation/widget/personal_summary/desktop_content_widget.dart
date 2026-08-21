part of 'personal_summary_widget.dart';

class _DesktopContentWidget extends StatelessWidget {
  const _DesktopContentWidget({required this.profile, required this.isVisible});

  final ProfileEntity profile;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final imageHeight = context.space(factor: 30);
    final blobColor = context.colorPalette.accent;

    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: context.width * 0.15,
          child: DSGradientBlobWidget(
            size: imageHeight * 0.7,
            colors: [
              blobColor.color.withAlpha(50),
              blobColor.color.withAlpha(70),
            ],
            scaleBegin: const Offset(1.0, 1.0),
            scaleEnd: const Offset(1.05, 1.05),
            duration: 4.seconds,
          ),
        ),
        Positioned(
          top: imageHeight * 0.6,
          left: 0,
          child: DSGradientBlobWidget(
            size: imageHeight * 0.75,
            colors: [
              blobColor.color.withAlpha(100),
              blobColor.color.withAlpha(220),
            ],
            scaleBegin: const Offset(1.1, 1.1),
            scaleEnd: const Offset(0.95, 0.95),
            duration: 5.seconds,
          ),
        ),
        Positioned(
          bottom: -context.space(factor: 3),
          left: context.width * 0.3,
          child: DSGradientBlobWidget(
            size: imageHeight * 0.6,
            colors: [
              blobColor.color.withAlpha(150),
              blobColor.color.withAlpha(250),
            ],
            scaleBegin: const Offset(1.2, 1.2),
            scaleEnd: const Offset(1.0, 1.0),
            duration: 3.seconds,
          ),
        ),
        Column(
          spacing: context.space(factor: 2),
          children: [
            _RightCardWidget(
              margin: EdgeInsets.only(left: context.width * 0.15),
              isVisible: isVisible,
              animationDelay: 0.ms,
              child: _SummaryWidget(summary: profile.summary),
            ),
            _RightCardWidget(
              margin: EdgeInsets.only(left: context.width * 0.3),
              isVisible: isVisible,
              animationDelay: 300.ms,
              child: _EducationWidget(education: profile.educations.first),
            ),
            _RightCardWidget(
              margin: EdgeInsets.only(left: context.width * 0.45),
              isVisible: isVisible,
              animationDelay: 600.ms,
              child: _IntroWidget(
                name: profile.fullName,
                title: profile.subtitle,
                subtitle:
                    '${profile.location.city}, ${profile.location.country}',
              ),
            ),
            _DetailButtonWidget(
              isVisible: true,
              animationDelay: 900.ms,
              margin: EdgeInsets.only(right: context.width * 0.35),
            ),
            const DSVerticalSpacerWidget(0.1),
          ],
        ),
        Positioned(
          bottom: 0,
          left: context.width * 0.0,
          height: imageHeight,
          width: imageHeight,
          child: _ProfileImageWidget(
            url: profile.coverImage,
            isVisible: isVisible,
            animationDelay: 200.ms,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
