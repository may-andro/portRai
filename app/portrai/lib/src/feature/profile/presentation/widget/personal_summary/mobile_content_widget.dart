part of 'personal_summary_widget.dart';

class _MobileContentWidget extends StatelessWidget {
  const _MobileContentWidget({required this.profile, required this.isVisible});

  final ProfileEntity profile;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final height = context.height;
    final blobColor = context.colorPalette.accent;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: DSGradientBlobWidget(
              size: height * 0.5,
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
            top: height * 0.7,
            left: 0,
            child: DSGradientBlobWidget(
              size: height * 0.6,
              colors: [
                blobColor.color.withAlpha(100),
                blobColor.color.withAlpha(220),
              ],
              scaleBegin: const Offset(1.1, 1.1),
              scaleEnd: const Offset(0.95, 0.95),
              duration: 5.seconds,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RightCardWidget(
                margin: context.mobileRightCardMargin,
                isVisible: isVisible,
                animationDelay: 0.ms,
                child: _SummaryWidget(summary: profile.summary),
              ),
              const DSVerticalSpacerWidget(2),
              Align(
                alignment: Alignment.centerLeft,
                child: _LeftCardWidget(
                  margin: context.mobileLeftCardMargin,
                  isVisible: isVisible,
                  animationDelay: 300.ms,
                  child: _IntroWidget(
                    name: profile.fullName,
                    title: profile.title,
                    subtitle:
                        '${profile.location.city}, ${profile.location.country}',
                  ),
                ),
              ),
              const DSVerticalSpacerWidget(2),
              _RightCardWidget(
                margin: context.mobileRightCardMargin,
                isVisible: isVisible,
                animationDelay: 600.ms,
                child: _EducationWidget(education: profile.educations.first),
              ),
              Expanded(
                child: _ProfileImageWidget(
                  url: profile.coverImage,
                  isVisible: isVisible,
                  animationDelay: 900.ms,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: context.space(factor: 2),
            right: context.space(factor: 2),
            child: _DetailButtonWidget(isVisible: true, animationDelay: 900.ms),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  EdgeInsets get mobileLeftCardMargin {
    return EdgeInsets.only(right: kIsWeb ? width * 0.2 : space(factor: 3));
  }

  EdgeInsets get mobileRightCardMargin {
    return EdgeInsets.only(left: kIsWeb ? width * 0.2 : space(factor: 3));
  }
}
