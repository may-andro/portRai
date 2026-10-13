part of 'content_widget.dart';

class _AboutBandWidget extends StatelessWidget {
  const _AboutBandWidget({required this.profile, required this.isDesktop});

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final photoWidth = isDesktop
        ? min(context.width * 0.34, 460.0)
        : min(context.width * 0.78, 340.0);
    final photo = _BlobPhotoWidget(url: profile.photoAt(2), width: photoWidth);
    final text = _AboutTextWidget(profile: profile, isDesktop: isDesktop);

    return _BandWidget(
      color: context.colorPalette.surface.surface.color,
      child: isDesktop
          ? Row(
              spacing: context.space(factor: 8),
              children: [
                photo,
                Expanded(child: text),
              ],
            )
          : Column(spacing: context.space(factor: 4), children: [photo, text]),
    );
  }
}

class _AboutTextWidget extends StatelessWidget {
  const _AboutTextWidget({required this.profile, required this.isDesktop});

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 2),
      children: [
        _EyebrowWidget(context.localizations.profileAboutMe),
        DSTextWidget(
          profile.currentRole,
          style: isDesktop
              ? context.typography.emphasizedDisplaySmall
              : context.typography.emphasizedHeadlineMedium,
          color: palette.neutral.grey10,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: 0.75),
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 20,
              color: palette.brand.primary.color,
            ),
            Flexible(
              child: DSTextWidget(
                profile.currentCompany,
                style: context.typography.emphasizedTitleMedium,
                color: palette.brand.primary,
              ),
            ),
          ],
        ),
        DSTextWidget(
          profile.elevatorPitch,
          style: isDesktop
              ? context.typography.bodyLarge
              : context.typography.bodyMedium,
          color: palette.neutral.grey8,
        ),
        Wrap(
          spacing: context.space(factor: 3),
          runSpacing: context.space(factor: 1.5),
          children: [
            _AboutFactWidget(
              icon: Icons.place_outlined,
              text: '${profile.location.city}, ${profile.location.country}',
            ),
            if (profile.languages.isNotEmpty)
              _AboutFactWidget(
                icon: Icons.translate_rounded,
                text: profile.languages
                    .map((entry) => '${entry.language} (${entry.proficiency})')
                    .join(' · '),
              ),
          ],
        ),
        SizedBox(height: context.space(factor: 0.5)),
        Wrap(
          spacing: context.space(factor: 2),
          runSpacing: context.space(factor: 2),
          children: [
            _DownloadResumeButtonWidget(resumeUrl: profile.resume.url),
          ],
        ),
      ],
    );
  }
}

class _AboutFactWidget extends StatelessWidget {
  const _AboutFactWidget({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.space(factor: 0.75),
      children: [
        Icon(icon, size: 20, color: palette.brand.primary.color),
        Flexible(
          child: DSTextWidget(
            text,
            style: context.typography.emphasizedBodyMedium,
            color: palette.neutral.grey10,
          ),
        ),
      ],
    );
  }
}

/// Organic gradient blob holding a photo, with a pale shape behind it.
class _BlobPhotoWidget extends StatefulWidget {
  const _BlobPhotoWidget({required this.url, required this.width});

  final String url;
  final double width;

  @override
  State<_BlobPhotoWidget> createState() => _BlobPhotoWidgetState();
}

class _BlobPhotoWidgetState extends State<_BlobPhotoWidget> {
  bool _hovering = false;

  BorderRadius _shape(double photoWidth) => BorderRadius.only(
    topLeft: Radius.circular(photoWidth * 0.5),
    topRight: Radius.circular(photoWidth * 0.16),
    bottomRight: Radius.circular(photoWidth * 0.5),
    bottomLeft: Radius.circular(photoWidth * 0.16),
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final photoWidth = widget.width;
    final photoHeight = photoWidth * 1.05;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.03 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: SizedBox(
          width: photoWidth,
          height: photoHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -photoWidth * 0.08,
                top: photoHeight * 0.06,
                width: photoWidth,
                height: photoHeight,
                child: Transform.rotate(
                  angle: -0.12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(photoWidth * 0.45),
                      color: palette.brand.primary.color.withAlpha(30),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: _shape(photoWidth),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        palette.brand.primary.color,
                        palette.brand.secondary.color,
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: _shape(photoWidth),
                    child: DSNetworkImageWidget(
                      url: widget.url,
                      fit: BoxFit.fitHeight,
                      width: photoWidth,
                      height: photoHeight,
                    ),
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
