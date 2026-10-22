part of 'content_widget.dart';

class _BodyWidget extends StatelessWidget {
  const _BodyWidget({required this.profile, required this.workPlaces});

  final ProfileEntity profile;
  final List<WorkPlaceEntity> workPlaces;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroWidget(profile: profile, isDesktop: isDesktop),
        _GlobalBandWidget(
          profile: profile,
          workPlaces: workPlaces,
          isDesktop: isDesktop,
        ),
        _AboutBandWidget(profile: profile, isDesktop: isDesktop),
        _BackgroundBandWidget(profile: profile, isDesktop: isDesktop),
        _ContactBandWidget(profile: profile, isDesktop: isDesktop),
      ],
    );
  }
}
