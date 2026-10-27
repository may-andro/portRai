import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/widget/page_band_widget.dart';
import 'package:portrai/src/widget/page_technology_chip_widget.dart';

/// The long project story, kept to a comfortable reading width.
class ProjectOverviewWidget extends StatelessWidget {
  const ProjectOverviewWidget({super.key, required this.project});

  final ProjectEntity project;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: DSTextWidget(
        project.longDescription,
        style: context.typography.bodyLarge,
        color: context.colorPalette.neutral.grey9,
      ),
    );
  }
}

/// Oversized, faded app icon that sways and bobs inside a slowly turning
/// gradient ring, drifting behind the overview text.
class ProjectImageBackdropWidget extends StatelessWidget {
  const ProjectImageBackdropWidget({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    final secondary = palette.brand.tertiary.color;
    final size = context.isDesktop ? 520.0 : 300.0;
    return DSOffscreenPauseWidget(
      child: IgnorePointer(
        child: ClipRect(
          child: Align(
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: Offset(size * 0.25, 0),
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                accent.withAlpha(0),
                                accent.withAlpha(70),
                                secondary.withAlpha(0),
                                secondary.withAlpha(70),
                                accent.withAlpha(0),
                              ],
                            ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(duration: 24.seconds),
                    Container(
                      width: size * 0.9,
                      height: size * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.surface.surface.color,
                      ),
                    ),
                    Container(
                          width: size * 0.5,
                          height: size * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(size * 0.12),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withAlpha(50),
                                blurRadius: 60,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Opacity(
                            opacity: 0.16,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(size * 0.12),
                              child: DSNetworkImageWidget(
                                url: imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .rotate(
                          begin: -0.025,
                          end: 0.025,
                          duration: 6.seconds,
                          curve: Curves.easeInOut,
                        )
                        .moveY(
                          begin: -12,
                          end: 12,
                          duration: 4.seconds,
                          curve: Curves.easeInOut,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Map showing every market the project is available in.
class ProjectMarketsWidget extends StatelessWidget {
  const ProjectMarketsWidget({super.key, required this.markets});

  final List<ProjectMarketEntity> markets;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final positions = [
      for (final market in markets) LatLng(market.latitude, market.longitude),
    ];
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
    return Column(
      spacing: context.space(factor: 2),
      children: [
        ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            height: context.isDesktop ? 420 : 280,
            width: double.infinity,
            child: IgnorePointer(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: positions.first,
                  zoom: positions.length > 1 ? 3 : 5,
                ),
                onMapCreated: (controller) {
                  if (positions.length < 2) return;
                  controller.moveCamera(
                    CameraUpdate.newLatLngBounds(_boundsOf(positions), 56),
                  );
                },
                markers: {
                  for (final market in markets)
                    Marker(
                      markerId: MarkerId(market.country),
                      position: LatLng(market.latitude, market.longitude),
                      infoWindow: InfoWindow(title: market.country),
                    ),
                },
                // The map never moves, so Android draws it as a still image
                // instead of a live view, which is far cheaper to create and to
                // scroll past.
                liteModeEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
        ),
        Wrap(
          spacing: context.space(),
          runSpacing: context.space(),
          alignment: WrapAlignment.center,
          children: [
            for (final market in markets)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(factor: 1.5),
                  vertical: context.space(factor: 0.75),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    context.dimen.radiusLevel3.value,
                  ),
                  color: palette.surface.surface.color,
                  border: Border.all(color: palette.neutral.grey3.color),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: context.space(factor: 0.75),
                  children: [
                    Icon(
                      Icons.place_rounded,
                      size: 16,
                      color: palette.brand.primary.color,
                    ),
                    DSTextWidget(
                      market.country,
                      style: context.typography.emphasizedLabelLarge,
                      color: palette.neutral.grey10,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  LatLngBounds _boundsOf(List<LatLng> positions) {
    final latitudes = positions.map((position) => position.latitude);
    final longitudes = positions.map((position) => position.longitude);
    return LatLngBounds(
      southwest: LatLng(
        latitudes.reduce((first, second) => first < second ? first : second),
        longitudes.reduce((first, second) => first < second ? first : second),
      ),
      northeast: LatLng(
        latitudes.reduce((first, second) => first > second ? first : second),
        longitudes.reduce((first, second) => first > second ? first : second),
      ),
    );
  }
}

/// Features as a compact, multi-column checklist.
class ProjectFeatureBentoWidget extends StatelessWidget {
  const ProjectFeatureBentoWidget({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final gap = context.space(factor: 2);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final columnWidth =
            (constraints.maxWidth - gap * (columnCount - 1)) / columnCount;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (index, item) in items.indexed)
              SizedBox(
                width: columnWidth.floorToDouble(),
                child:
                    Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: context.space(factor: 1.5),
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 22,
                              color: palette.brand.primary.color,
                            ),
                            Expanded(
                              child: DSTextWidget(
                                item,
                                style: context.typography.bodyLarge,
                                color: palette.neutral.grey10,
                              ),
                            ),
                          ],
                        )
                        .animate(delay: (index * 60).ms)
                        .fadeIn()
                        .slideY(begin: 0.1, end: 0),
              ),
          ],
        );
      },
    );
  }
}

/// Technologies in slowly auto-scrolling rows; hovering a row pauses it.
class ProjectTechMarqueeWidget extends StatelessWidget {
  const ProjectTechMarqueeWidget({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final splitAt = (items.length / 2).ceil();
    final hasSecondRow = items.length >= 6;
    final firstRow = hasSecondRow ? items.sublist(0, splitAt) : items;
    final secondRow = hasSecondRow ? items.sublist(splitAt) : const <String>[];
    final inset = context.screenHorizontalPadding.left;
    final rowCount = secondRow.isEmpty ? 1 : 2;
    final height =
        rowCount * _MarqueeRowWidgetState.rowHeight +
        (rowCount - 1) * context.space();
    // Breaks out of the band's horizontal padding so the rows run edge to edge.
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        height: height,
        child: OverflowBox(
          minWidth: constraints.maxWidth + inset * 2,
          maxWidth: constraints.maxWidth + inset * 2,
          child: _fadedRows(context, firstRow, secondRow),
        ),
      ),
    );
  }

  Widget _fadedRows(
    BuildContext context,
    List<String> firstRow,
    List<String> secondRow,
  ) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
            Colors.transparent,
          ],
          stops: [0, 0.04, 0.96, 1],
        ).createShader(bounds);
      },
      child: Column(
        spacing: context.space(),
        children: [
          _MarqueeRowWidget(items: firstRow, isReversed: false),
          if (secondRow.isNotEmpty)
            _MarqueeRowWidget(items: secondRow, isReversed: true),
        ],
      ),
    );
  }
}

class _MarqueeRowWidget extends StatefulWidget {
  const _MarqueeRowWidget({required this.items, required this.isReversed});

  final List<String> items;
  final bool isReversed;

  @override
  State<_MarqueeRowWidget> createState() => _MarqueeRowWidgetState();
}

class _MarqueeRowWidgetState extends State<_MarqueeRowWidget>
    with SingleTickerProviderStateMixin {
  static const rowHeight = 68.0;
  static const _pixelsPerSecond = 38.0;

  final _scrollController = ScrollController();
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final deltaSeconds = (elapsed - _lastElapsed).inMicroseconds / 1000000;
    _lastElapsed = elapsed;
    if (_isPaused || !_scrollController.hasClients) return;
    _scrollController.jumpTo(
      _scrollController.offset + _pixelsPerSecond * deltaSeconds,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _isPaused = true,
      onExit: (_) => _isPaused = false,
      child: SizedBox(
        height: rowHeight,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          reverse: widget.isReversed,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(right: context.space(factor: 1.5)),
                child: PageTechnologyChipWidget(
                  label: widget.items[index % widget.items.length],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Achievements as a vertical timeline: numbered nodes joined by a line.
class ProjectAchievementStripWidget extends StatelessWidget {
  const ProjectAchievementStripWidget({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.brand.primary.color;
    const nodeSize = 36.0;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: Column(
        children: [
          for (final (index, item) in items.indexed)
            IntrinsicHeight(
              child:
                  Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: context.space(factor: 2),
                        children: [
                          SizedBox(
                            width: nodeSize,
                            child: Column(
                              children: [
                                Container(
                                  width: nodeSize,
                                  height: nodeSize,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        accent,
                                        palette.brand.tertiary.color,
                                      ],
                                    ),
                                  ),
                                  child: DSTextWidget(
                                    '${index + 1}',
                                    style:
                                        context.typography.emphasizedLabelLarge,
                                    color: pageOnDarkColor,
                                  ),
                                ),
                                if (index < items.length - 1)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: accent.withAlpha(60),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: context.space(factor: 0.75),
                                bottom: context.space(factor: 3),
                              ),
                              child: DSTextWidget(
                                item,
                                style: context.typography.bodyLarge,
                                color: palette.neutral.grey10,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate(delay: (index * 80).ms)
                      .fadeIn()
                      .slideX(begin: 0.03, end: 0),
            ),
        ],
      ),
    );
  }
}
