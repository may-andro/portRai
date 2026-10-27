import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

part 'expertise_card_widget.dart';

part 'expertise_grid_widget.dart';

class ExpertiseListWidget extends StatelessWidget {
  const ExpertiseListWidget({
    super.key,
    required this.allExpertise,
    required this.isVisible,
    this.visibleItemsCount,
    required this.onClicked,
  });

  final List<ExpertiseEntity> allExpertise;
  final bool isVisible;
  final int? visibleItemsCount;

  /// Called with the expertise that is tapped to be opened. The caller decides
  /// what the tap does, such as opening the expertise.
  final ValueChanged<ExpertiseEntity> onClicked;

  @override
  Widget build(BuildContext context) {
    if (allExpertise.isEmpty) {
      return const SizedBox.shrink();
    }

    final count = visibleItemsCount;

    return _GridWidget(
      expertises: !context.isDesktop && count != null
          ? allExpertise.take(count).toList()
          : allExpertise,
      isVisible: isVisible,
      onClicked: onClicked,
    );
  }
}
