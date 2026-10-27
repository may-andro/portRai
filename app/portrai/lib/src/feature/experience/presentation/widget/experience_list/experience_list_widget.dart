import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/extension/experience_date_range_extension.dart';
import 'package:portrai/src/feature/experience/presentation/screen/_screen.dart';
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
    this.onOpen,
  });

  final List<ExperienceEntity> experiences;
  final bool isVisible;
  final int? visibleItemsCount;

  /// Called when an experience is opened, before its screen is shown, so the
  /// host screen can track the tap.
  final ValueChanged<ExperienceEntity>? onOpen;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final count = visibleItemsCount;
    return _CareerTimelineWidget(
      experiences: !isDesktop && count != null
          ? experiences.take(count).toList()
          : experiences,
      isVisible: isVisible,
      isZigZag: isDesktop,
      onOpen: onOpen,
    );
  }
}
