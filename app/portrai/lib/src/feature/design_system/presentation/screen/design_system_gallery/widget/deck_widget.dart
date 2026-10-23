part of 'content_widget.dart';

/// A loose stack of cards: the front card follows the finger and is tossed
/// aside with a twist, while the cards behind peek out above it, fanned left
/// and right, and move up as the front card leaves.
class _DeckWidget extends StatelessWidget {
  const _DeckWidget({
    required this.deckPosition,
    required this.designSystemAt,
    required this.state,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  /// Cards behind the front one that are drawn.
  static const _visibleDepth = 3;

  /// Width over height of a card, close to a playing card.
  static const _cardAspectRatio = 0.68;

  /// How much smaller each card behind the front one is.
  static const _scaleStep = 0.06;

  /// How far a tossed card travels, in cards, before it has faded out. It is
  /// gone well before the next card settles, so a spring that eases or
  /// bounces around the next card never brings it back into view.
  static const _tossFadeEnd = 0.75;

  final Animation<double> deckPosition;
  final DesignSystem Function(int deckPosition) designSystemAt;
  final DesignSystemGalleryLoadedState state;
  final VoidCallback onDragStart;

  /// Gets the cards moved, positive towards the next card.
  final ValueChanged<double> onDragUpdate;

  /// Gets the fling speed in cards per second, positive towards the next card.
  final ValueChanged<double> onDragEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final peek = context.space(factor: 1.5);
        final cardHeight = math.min(
          constraints.maxHeight -
              peek * _visibleDepth -
              context.space(factor: 2),
          constraints.maxWidth * 0.82 / _cardAspectRatio,
        );
        final cardSize = Size(cardHeight * _cardAspectRatio, cardHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => onDragStart(),
          onHorizontalDragUpdate: (details) =>
              onDragUpdate(-(details.primaryDelta ?? 0) / cardSize.width),
          onHorizontalDragEnd: (details) =>
              onDragEnd(-(details.primaryVelocity ?? 0) / cardSize.width),
          child: AnimatedBuilder(
            animation: deckPosition,
            builder: (context, _) => Stack(
              alignment: Alignment.center,
              children: [
                for (
                  var cardPosition = deckPosition.value.floor() + _visibleDepth;
                  cardPosition >= deckPosition.value.floor();
                  cardPosition--
                )
                  _placeCard(
                    context,
                    cardPosition: cardPosition,
                    cardSize: cardSize,
                    peek: peek,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _placeCard(
    BuildContext context, {
    required int cardPosition,
    required Size cardSize,
    required double peek,
  }) {
    // Below zero the card is leaving the front; above zero it waits behind.
    final depth = cardPosition - deckPosition.value;
    final fanSide = cardPosition.isEven ? 1 : -1;
    final double horizontalShift;
    final double verticalShift;
    final double turn;
    final double scale;
    final double opacity;
    if (depth <= 0) {
      final leaving = -depth;
      horizontalShift = -leaving * cardSize.width * 1.5;
      verticalShift = leaving * peek * 2;
      turn = -leaving * 0.3;
      scale = 1;
      opacity = (1 - leaving / _tossFadeEnd).clamp(0, 1).toDouble();
    } else {
      scale = 1 - depth * _scaleStep;
      horizontalShift = 0;
      // Lifts the card by what shrinking took off its top edge, plus the peek.
      verticalShift = -depth * (cardSize.height * _scaleStep / 2 + peek);
      turn = fanSide * math.min(depth, 1) * 0.06;
      opacity = (_visibleDepth + 1 - depth).clamp(0, 1).toDouble();
    }
    // A card gone from view is skipped, so it neither paints nor animates.
    if (opacity == 0) return SizedBox.shrink(key: ValueKey(cardPosition));
    final designSystem = designSystemAt(cardPosition);
    return Transform.translate(
      key: ValueKey(cardPosition),
      offset: Offset(horizontalShift, verticalShift + peek * _visibleDepth / 2),
      child: Transform.rotate(
        angle: turn,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: SizedBox.fromSize(
              size: cardSize,
              child: _ThemeCardWidget(
                designSystem: designSystem,
                month: state.monthOf(designSystem),
                isMonthly: designSystem == state.monthlyDesignSystem,
                isApplied: designSystem == state.appliedDesignSystem,
                isAnimated: depth < 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
