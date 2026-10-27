part of 'personal_summary_widget.dart';

class _ContentWidget extends StatelessWidget {
  const _ContentWidget({required this.profile, required this.isVisible});

  final ProfileEntity profile;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final firstName = profile.fullName.split(' ').first;

    final background = Positioned.fill(
      child: DSFloatingShapesBackgroundWidget(
        color: context.colorPalette.accent.color,
      ),
    );

    if (context.isMobile) {
      final imageHeight = (context.width * 0.85).clamp(260.0, 380.0);
      return Column(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 3),
        children: [
          SizedBox(
            height: imageHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                background,
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _BackdropNameWidget(
                    name: firstName,
                    isVisible: isVisible,
                  ),
                ),
                _ProfileImageWidget(
                  url: profile.profileImage,
                  isVisible: isVisible,
                  height: imageHeight,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: context.space(factor: 4)),
            child: _DetailsWidget(
              profile: profile,
              isVisible: isVisible,
              isCentered: true,
            ),
          ),
        ],
      );
    }

    final height = (context.width * 0.42).clamp(380.0, 580.0);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        background,
        Positioned(
          top: height * 0.05,
          left: 0,
          right: 0,
          child: _BackdropNameWidget(name: firstName, isVisible: isVisible),
        ),
        Positioned.fill(
          child: Row(
            children: [
              const Spacer(),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _ProfileImageWidget(
                    url: profile.profileImage,
                    isVisible: isVisible,
                    height: height,
                  ),
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.space(factor: 3)),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _DetailsWidget(
                        profile: profile,
                        isVisible: isVisible,
                        isCentered: false,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
