import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/extension/experience_date_range_extension.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/experience_screen.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';

part 'career_timeline_widget.dart';

part 'experience_card_widget.dart';

part 'date_location_widget.dart';

part 'description_widget.dart';

part 'image_widget.dart';

class ExperienceListWidget extends StatelessWidget {
  const ExperienceListWidget({
    super.key,
    required this.experiences,
    required this.isVisible,
    this.visibleItemsCount,
  });

  final List<ExperienceEntity> experiences;
  final bool isVisible;
  final int? visibleItemsCount;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final count = visibleItemsCount;
    return BlocProvider(
      create: (_) => appServiceLocator.get<ExperienceListBloc>(),
      child: _CareerTimelineWidget(
        experiences: !isDesktop && count != null
            ? experiences.take(count).toList()
            : experiences,
        isVisible: isVisible,
        isZigZag: isDesktop,
      ),
    );
  }
}
