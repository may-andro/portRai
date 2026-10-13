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
  });

  final List<ExpertiseEntity> allExpertise;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    if (allExpertise.isEmpty) {
      return const SizedBox.shrink();
    }

    return _GridWidget(expertises: allExpertise, isVisible: isVisible);
  }
}
