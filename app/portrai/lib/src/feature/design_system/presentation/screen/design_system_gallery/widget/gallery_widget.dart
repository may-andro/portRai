part of 'content_widget.dart';

/// Lays out the deck, the month dial and the apply panel over a backdrop,
/// all dressed in the design system of the card in front.
///
/// Owns the deck position, counted in cards. It grows without bound in both
/// directions, so the deck loops; the card at a position is the design system
/// at that position modulo the number of design systems.
class _GalleryWidget extends StatefulWidget {
  const _GalleryWidget({required this.state});

  final DesignSystemGalleryLoadedState state;

  @override
  State<_GalleryWidget> createState() => _GalleryWidgetState();
}

class _GalleryWidgetState extends State<_GalleryWidget>
    with SingleTickerProviderStateMixin {
  /// The narrowest landscape area that shows the deck and the controls side
  /// by side.
  static const _sideBySideMinWidth = 720.0;
  static const _stackedMaxWidth = 560.0;
  static const _panelMaxWidth = 440.0;

  static const _deckSpring = SpringDescription(
    mass: 1,
    stiffness: 170,
    damping: 22,
  );

  late final AnimationController _deckController =
      AnimationController.unbounded(
        vsync: this,
        value: widget.state.designSystems
            .indexOf(widget.state.previewedDesignSystem)
            .toDouble(),
      );

  List<DesignSystem> get _designSystems => widget.state.designSystems;

  @override
  void dispose() {
    _deckController.dispose();
    super.dispose();
  }

  DesignSystem _designSystemAt(int deckPosition) =>
      _designSystems[deckPosition % _designSystems.length];

  /// Springs the deck to [deckPosition], keeping [velocity] (cards per
  /// second) from a fling, and previews the card that lands in front.
  void _settleAt(int deckPosition, {double velocity = 0}) {
    final simulation = SpringSimulation(
      _deckSpring,
      _deckController.value,
      deckPosition.toDouble(),
      velocity,
    );
    _deckController.animateWith(simulation).then((_) {
      if (!mounted) return;
      _deckController.value = deckPosition.toDouble();
      context.bloc.add(
        PreviewDesignSystemClickEvent(_designSystemAt(deckPosition)),
      );
    });
  }

  void _onDragStart() => _deckController.stop();

  void _onDragUpdate(double cardsMoved) => _deckController.value += cardsMoved;

  void _onDragEnd(double cardsPerSecond) {
    final deckPosition = _deckController.value;
    final int targetPosition;
    if (cardsPerSecond.abs() > 0.6) {
      targetPosition = cardsPerSecond > 0
          ? deckPosition.floor() + 1
          : deckPosition.ceil() - 1;
    } else {
      targetPosition = deckPosition.round();
    }
    _settleAt(targetPosition, velocity: cardsPerSecond);
  }

  void _step(int cards) => _settleAt(_deckController.value.round() + cards);

  /// Takes the shortest way round the deck to [designSystem].
  void _showDesignSystem(DesignSystem designSystem) {
    final count = _designSystems.length;
    final frontPosition = _deckController.value.round();
    var cards =
        (_designSystems.indexOf(designSystem) - frontPosition % count) % count;
    if (cards > count ~/ 2) cards -= count;
    _settleAt(frontPosition + cards);
  }

  Widget _buildDeck() => _DeckWidget(
    deckPosition: _deckController,
    designSystemAt: _designSystemAt,
    state: widget.state,
    onDragStart: _onDragStart,
    onDragUpdate: _onDragUpdate,
    onDragEnd: _onDragEnd,
  );

  Widget _buildMonthDial() => _MonthDialWidget(
    deckPosition: _deckController,
    designSystems: _designSystems,
    onDesignSystemClick: _showDesignSystem,
    onPreviousClick: () => _step(-1),
    onNextClick: () => _step(1),
  );

  Widget _buildHint(BuildContext context) => _SteadyTextWidget(
    designSystems: _designSystems,
    textOf: (_) => context.localizations.themeGalleryHint,
    styleOf: (typography) => typography.bodyMedium,
    color: context.colorPalette.neutral.grey7,
  );

  /// Phones and portrait windows: the deck between the hint and the controls.
  Widget _buildStacked(BuildContext context) {
    return Padding(
      padding: context.screenHorizontalPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _stackedMaxWidth),
          child: Column(
            children: [
              _buildHint(context),
              Expanded(child: _buildDeck()),
              _buildMonthDial(),
              const DSVerticalSpacerWidget(1.5),
              _ApplyPanelWidget(state: widget.state),
              const DSVerticalSpacerWidget(2),
            ],
          ),
        ),
      ),
    );
  }

  /// Landscape windows: the deck on the left and the controls beside it.
  Widget _buildSideBySide(BuildContext context) {
    final state = widget.state;
    return Padding(
      padding: context.screenHorizontalPadding.copyWith(
        bottom: context.space(factor: 2),
      ),
      child: Row(
        children: [
          Expanded(flex: 5, child: _buildDeck()),
          const DSHorizontalSpacerWidget(4),
          Expanded(
            flex: 4,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _panelMaxWidth),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SteadyTextWidget(
                        designSystems: state.designSystems,
                        textOf: (designSystem) => designSystem.title(context),
                        styleOf: (typography) =>
                            typography.emphasizedDisplaySmall,
                        color: context.colorPalette.neutral.grey9,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                      const DSVerticalSpacerWidget(0.5),
                      _SteadyTextWidget(
                        designSystems: state.designSystems,
                        textOf: (designSystem) => designSystem.tagline(context),
                        styleOf: (typography) => typography.titleMedium,
                        color: context.colorPalette.neutral.grey7,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                      ),
                      const DSVerticalSpacerWidget(3),
                      _buildMonthDial(),
                      const DSVerticalSpacerWidget(3),
                      _ApplyPanelWidget(state: state),
                      const DSVerticalSpacerWidget(2),
                      _buildHint(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final brightness = context.platformBrightness;
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: DSThemeBuilderWidget(
            key: ValueKey(state.previewedDesignSystem),
            designSystem: state.previewedDesignSystem,
            brightness: brightness,
            child: const _AmbienceWidget(),
          ),
        ),
        DSThemeBuilderWidget(
          designSystem: state.previewedDesignSystem,
          brightness: brightness,
          child: Builder(
            builder: (context) => Column(
              children: [
                PageTopBarWidget(
                  title: context.localizations.themeGalleryTitle,
                  backgroundColor:
                      context.colorPalette.neutral.transparent.color,
                ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) =>
                          constraints.maxWidth > constraints.maxHeight &&
                              constraints.maxWidth >= _sideBySideMinWidth
                          ? _buildSideBySide(context)
                          : _buildStacked(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
