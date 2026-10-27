import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/expertise_screen.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_list/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

part 'expertise_card_widget.dart';

part 'expertise_grid_widget.dart';

class ExpertiseListWidget extends StatelessWidget {
  const ExpertiseListWidget({
    super.key,
    required this.allExpertise,
    required this.isVisible,
    this.visibleItemsCount,
  });

  final List<ExpertiseEntity> allExpertise;
  final bool isVisible;
  final int? visibleItemsCount;

  @override
  Widget build(BuildContext context) {
    if (allExpertise.isEmpty) {
      return const SizedBox.shrink();
    }

    final count = visibleItemsCount;

    return BlocProvider(
      create: (_) => appServiceLocator.get<ExpertiseListBloc>(),
      child: _GridWidget(
        expertises: !context.isDesktop && count != null
            ? allExpertise.take(count).toList()
            : allExpertise,
        isVisible: isVisible,
      ),
    );
  }
}
