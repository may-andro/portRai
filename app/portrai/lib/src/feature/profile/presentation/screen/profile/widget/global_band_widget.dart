part of 'content_widget.dart';

/// Brand band with the "worked across the globe" story, the key numbers and a
/// map marking every country the projects were shipped to.
class _GlobalBandWidget extends StatelessWidget {
  const _GlobalBandWidget({
    required this.profile,
    required this.workPlaces,
    required this.isDesktop,
  });

  final ProfileEntity profile;
  final List<WorkPlaceEntity> workPlaces;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final showMap = workPlaces.isNotEmpty && DSMapWidget.isSupported;
    final text = _GlobalTextWidget(
      profile: profile,
      workPlaces: workPlaces,
      isDesktop: isDesktop,
    );

    final chips = Wrap(
      spacing: context.space(),
      runSpacing: context.space(),
      children: [
        for (final place in workPlaces) _CountryChipWidget(place.country),
      ],
    );

    return PageBandWidget(
      verticalFactor: isDesktop ? 5 : 3,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [palette.brand.primary.color, palette.brand.secondary.color],
      ),
      background: const _BandDecorationWidget(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: context.space(factor: 4),
        children: [
          if (showMap && isDesktop)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: context.space(factor: 6),
                children: [
                  Expanded(flex: 5, child: text),
                  Expanded(
                    flex: 6,
                    child: _WorkMapWidget(places: workPlaces, fill: true),
                  ),
                ],
              ),
            )
          else ...[
            text,
            if (showMap) _WorkMapWidget(places: workPlaces),
          ],
          if (workPlaces.isNotEmpty) chips,
        ],
      ),
    );
  }
}

class _GlobalTextWidget extends StatelessWidget {
  const _GlobalTextWidget({
    required this.profile,
    required this.workPlaces,
    required this.isDesktop,
  });

  final ProfileEntity profile;
  final List<WorkPlaceEntity> workPlaces;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 2),
      children: [
        PageEyebrowWidget(localizations.profileGlobalEyebrow, onDark: true),
        DSTextWidget(
          localizations.profileGlobalTitle,
          style: isDesktop
              ? context.typography.emphasizedDisplaySmall
              : context.typography.emphasizedHeadlineMedium,
          color: pageOnDarkColor,
        ),
        DSTextWidget(
          localizations.profileGlobalDescription,
          style: context.typography.bodyLarge,
          color: pageOnDarkColor,
        ),
        SizedBox(height: context.space(factor: 0.5)),
        Wrap(
          spacing: context.space(factor: 4),
          runSpacing: context.space(factor: 2),
          children: [
            _GlobalStatWidget(
              icon: const DSLottieIconWidget(
                icon: DSLottieIcon.folder,
                size: 48,
                color: Colors.white,
                playback: DSLottiePlayback.loop,
              ),
              value: '${profile.projectsDelivered}+',
              label: localizations.profileProjects,
            ),
            if (workPlaces.isNotEmpty)
              _GlobalStatWidget(
                // The globe artwork fills only part of its canvas, so it is
                // scaled up to match the other stat icons.
                icon: SizedBox.square(
                  dimension: 48,
                  child: Transform.scale(
                    scale: 1.6,
                    child: const DSLottieIllustrationWidget(
                      illustration: DSLottieIllustration.globe,
                      width: 48,
                    ),
                  ),
                ),
                value: '${workPlaces.length}',
                label: localizations.profileCountries,
              )
            else
              _GlobalStatWidget(
                icon: const DSLottieIconWidget(
                  icon: DSLottieIcon.language,
                  size: 48,
                  color: Colors.white,
                  playback: DSLottiePlayback.loop,
                ),
                value: '${profile.languages.length}',
                label: localizations.profileLanguages,
              ),
          ],
        ),
      ],
    );
  }
}

class _GlobalStatWidget extends StatelessWidget {
  const _GlobalStatWidget({
    required this.icon,
    required this.value,
    required this.label,
  });

  final Widget icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return HoverLiftWidget(
      scale: 1.05,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 1.5),
        children: [
          icon,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CountUpWidget(
                value: value,
                style: context.typography.emphasizedHeadlineMedium,
                color: pageOnDarkColor,
              ),
              DSTextWidget(
                label.toUpperCase(),
                style: context.typography.emphasizedLabelMedium,
                color: pageOnDarkColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountryChipWidget extends StatelessWidget {
  const _CountryChipWidget(this.country);

  final String country;

  @override
  Widget build(BuildContext context) {
    return HoverLiftWidget(
      scale: 1.06,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.space(factor: 1.5),
          vertical: context.space(factor: 0.5),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(28),
          borderRadius: BorderRadius.circular(
            context.dimen.radiusCircular.value,
          ),
          border: Border.all(color: Colors.white.withAlpha(120)),
        ),
        child: DSTextWidget(
          country,
          style: context.typography.emphasizedLabelLarge,
          color: pageOnDarkColor,
        ),
      ),
    );
  }
}

/// Framed map marking every work place; the page keeps scrolling over it.
class _WorkMapWidget extends StatelessWidget {
  const _WorkMapWidget({required this.places, this.fill = false});

  final List<WorkPlaceEntity> places;

  /// Stretches to the parent's height instead of using a fixed aspect ratio.
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final map = DSMapWidget(
      places: [
        for (final place in places)
          DSMapPlace(
            latitude: place.latitude,
            longitude: place.longitude,
            label: place.country,
          ),
      ],
      marker: DSMapMarker.brand,
      style: DSMapStyle.minimal,
      maxZoom: 6,
      borderRadius: BorderRadius.circular(26),
    );
    return HoverLiftWidget(
      scale: 1.01,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withAlpha(150), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(70),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: fill
            ? ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 340),
                child: map,
              )
            : AspectRatio(aspectRatio: 4 / 3, child: map),
      ),
    );
  }
}
