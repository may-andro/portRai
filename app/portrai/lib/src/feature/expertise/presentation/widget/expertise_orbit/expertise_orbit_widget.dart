import 'dart:async';
import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/lottie/_lottie.dart';

part 'expertise_orbit_backdrop_widget.dart';

part 'expertise_orbit_dial_widget.dart';

part 'expertise_orbit_node_widget.dart';

part 'expertise_orbit_painter.dart';

part 'expertise_orbit_ring_widget.dart';

part 'expertise_orbit_spinner_widget.dart';

const _maxOrbitSide = 720.0;

/// Share of the screen height the orbit may take, so it fits on screen.
const _maxOrbitHeightShare = 0.75;

DSColor _dsColor(Color color) => DSColor(color.toARGB32());

/// Every expertise as a node on an orbit that is the whole section. Hovering
/// or tapping a node shows its name and skill count in the middle, with a
/// button to open it.
///
/// On mobile only the top of the orbit shows, as a dial that turns when
/// swiped, with the selected expertise in a card below. The dial spans the
/// full width and pads the card itself, so give it no horizontal padding.
///
/// Pass a [selection] to share the selected expertise with
/// [ExpertiseOrbitBackdropWidget]; otherwise the selection is kept inside.
class ExpertiseOrbitWidget extends StatefulWidget {
  const ExpertiseOrbitWidget({
    super.key,
    required this.expertises,
    required this.isVisible,
    this.selection,
    required this.onClicked,
  });

  final List<ExpertiseEntity> expertises;
  final bool isVisible;
  final ValueNotifier<int>? selection;

  /// Called with the expertise that is tapped to be opened. The caller decides
  /// what the tap does, such as opening the expertise.
  final ValueChanged<ExpertiseEntity> onClicked;

  @override
  State<ExpertiseOrbitWidget> createState() => _ExpertiseOrbitWidgetState();
}

class _ExpertiseOrbitWidgetState extends State<ExpertiseOrbitWidget> {
  late final ValueNotifier<int> _ownSelection = ValueNotifier(0);

  ValueNotifier<int> get _selection => widget.selection ?? _ownSelection;

  @override
  void dispose() {
    _ownSelection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expertises.isEmpty) return const SizedBox.shrink();

    if (context.isMobile) {
      return _OrbitDialWidget(
        expertises: widget.expertises,
        selection: _selection,
        isVisible: widget.isVisible,
        onClicked: widget.onClicked,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = [
          constraints.maxWidth,
          _maxOrbitSide,
          context.height * _maxOrbitHeightShare,
        ].reduce(min);
        return Center(
          child: SizedBox.square(
            dimension: side,
            child: ValueListenableBuilder<int>(
              valueListenable: _selection,
              builder: (context, index, _) {
                return _OrbitRingWidget(
                  expertises: widget.expertises,
                  selected: min(index, widget.expertises.length - 1),
                  onSelect: (value) => _selection.value = value,
                  isVisible: widget.isVisible,
                  onClicked: widget.onClicked,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
