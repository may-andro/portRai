part of 'content_widget.dart';

/// The page bands as a lazy list: a band is built when it nears the viewport,
/// so opening the screen lays out only the first ones. Built bands are kept
/// alive, so the map and a typed message survive scrolling away.
class _BodyWidget extends StatelessWidget {
  const _BodyWidget({required this.profile, required this.workPlaces});

  final ProfileEntity profile;
  final List<WorkPlaceEntity> workPlaces;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    return SliverList.list(
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
      ].map((band) => _KeepAliveWidget(child: band)).toList(),
    );
  }
}

class _KeepAliveWidget extends StatefulWidget {
  const _KeepAliveWidget({required this.child});

  final Widget child;

  @override
  State<_KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<_KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
