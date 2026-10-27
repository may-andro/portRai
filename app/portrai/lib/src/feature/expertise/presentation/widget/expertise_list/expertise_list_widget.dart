import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/_screen.dart';

part 'expertise_card_widget.dart';

part 'expertise_grid_widget.dart';

class ExpertiseListWidget extends StatelessWidget {
  const ExpertiseListWidget({
    super.key,
    required this.allExpertise,
    required this.isVisible,
    this.visibleItemsCount,
    this.onOpen,
  });

  final List<ExpertiseEntity> allExpertise;
  final bool isVisible;
  final int? visibleItemsCount;

  /// Called when an expertise is opened, before its screen is shown, so the
  /// host screen can track the tap.
  final ValueChanged<ExpertiseEntity>? onOpen;

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
      onOpen: onOpen,
    );
  }
}
