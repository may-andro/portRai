import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/_screen.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/lottie/_lottie.dart';

part 'expertise_orbit_backdrop_widget.dart';

part 'expertise_orbit_painter.dart';

part 'expertise_orbit_ring_widget.dart';

part 'expertise_orbit_spinner_widget.dart';

const _maxOrbitSide = 560.0;

DSColor _dsColor(Color color) => DSColor(color.toARGB32());

/// Every expertise as a node on an orbit that is the whole section. Hovering
/// or tapping a node shows its name and skill count in the middle, with a
/// button to open it.
///
/// Pass a [selection] to share the selected expertise with
/// [ExpertiseOrbitBackdropWidget]; otherwise the selection is kept inside.
class ExpertiseOrbitWidget extends StatefulWidget {
  const ExpertiseOrbitWidget({
    super.key,
    required this.expertises,
    required this.isVisible,
    this.selection,
  });

  final List<ExpertiseEntity> expertises;
  final bool isVisible;
  final ValueNotifier<int>? selection;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth, _maxOrbitSide);
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
                );
              },
            ),
          ),
        );
      },
    );
  }
}
