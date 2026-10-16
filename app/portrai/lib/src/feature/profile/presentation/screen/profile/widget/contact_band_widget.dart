part of 'content_widget.dart';

/// Closing band over a photo: headline plus a message box that opens the
/// mail app with the typed message.
class _ContactBandWidget extends StatelessWidget {
  const _ContactBandWidget({required this.profile, required this.isDesktop});

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 2),
      children: [
        PageEyebrowWidget(localizations.profileContact, onDark: true),
        DSTextWidget(
          localizations.profileGetInTouch,
          style: isDesktop
              ? context.typography.emphasizedDisplayMedium
              : context.typography.emphasizedHeadlineLarge,
          color: pageOnDarkColor,
        ),
      ],
    );
    final card = _MessageCardWidget(profile: profile);

    return PageBandWidget(
      verticalFactor: isDesktop ? 5 : 3,
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/profile/contact_background.jpg',
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withAlpha(215),
                  Colors.black.withAlpha(120),
                ],
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 3),
        children: [
          heading,
          if (isDesktop)
            Row(
              spacing: context.space(factor: 3),
              children: [
                Flexible(
                  flex: 3,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: card,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) => Center(
                      child: DSLottieIllustrationWidget(
                        illustration: DSLottieIllustration.contactUs,
                        width: min(constraints.maxWidth, 420),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            card,
        ],
      ),
    );
  }
}

class _BandDecorationWidget extends StatelessWidget {
  const _BandDecorationWidget();

  @override
  Widget build(BuildContext context) {
    Widget circle(double size, int alpha) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(alpha),
      ),
    );
    return ClipRect(
      child: Stack(
        children: [
          Positioned(left: -80, bottom: -120, child: circle(320, 18)),
          Positioned(left: 220, top: -60, child: circle(120, 12)),
          Positioned(right: -100, top: -140, child: circle(360, 14)),
        ],
      ),
    );
  }
}

class _MessageCardWidget extends StatefulWidget {
  const _MessageCardWidget({required this.profile});

  final ProfileEntity profile;

  @override
  State<_MessageCardWidget> createState() => _MessageCardWidgetState();
}

class _MessageCardWidgetState extends State<_MessageCardWidget> {
  final _controller = TextEditingController();
  int _sendCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    setState(() => _sendCount++);
    final subject = Uri.encodeComponent(
      context.localizations.profileGetInTouch,
    );
    final body = Uri.encodeComponent(_controller.text.trim());
    context.bloc.add(
      OpenExternalUrlEvent(
        url: 'mailto:${widget.profile.email}?subject=$subject&body=$body',
        label: 'Email',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
    const ink = Color(0xFF1B1B1F);
    return HoverLiftWidget(
      scale: 1.01,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(90),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/profile/contact_phone.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: ColoredBox(color: Colors.white.withAlpha(185)),
              ),
              Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: EdgeInsets.all(context.space(factor: 3)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: context.space(factor: 2),
                    children: [
                      TextField(
                        controller: _controller,
                        minLines: 5,
                        maxLines: 8,
                        cursorColor: palette.brand.primary.color,
                        style: context.typography.bodyLarge.textStyle.copyWith(
                          color: ink,
                        ),
                        decoration: InputDecoration(
                          hintText: context.localizations.profileMessageHint,
                          hintStyle: context.typography.bodyLarge.textStyle
                              .copyWith(color: ink.withAlpha(140)),
                          filled: true,
                          fillColor: Colors.white.withAlpha(200),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              context.dimen.radiusLevel2.value,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              context.dimen.radiusLevel2.value,
                            ),
                            borderSide: BorderSide(
                              color: palette.brand.primary.color,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: HoverLiftWidget(
                          child: DSButtonWidget(
                            label: context.localizations.profileGetInTouch,
                            iconDirection: DSButtonIconDirection.right,
                            isExpanded: false,
                            iconWidget: DSLottieIconWidget(
                              icon: DSLottieIcon.paperPlane,
                              size: 32,
                              color: palette.brand.onPrimary.color,
                              playback: DSLottiePlayback.trigger,
                              trigger: _sendCount,
                            ),
                            onPressed: _send,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
