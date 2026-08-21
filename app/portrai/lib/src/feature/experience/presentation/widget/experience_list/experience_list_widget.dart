import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/_screen.dart';

part 'mobile_content_widget.dart';

part 'tablet_content_widget.dart';

part 'desktop_content_widget.dart';

part 'date_location_widget.dart';

part 'description_widget.dart';

part 'image_widget.dart';

part 'technologies_widget.dart';

part 'title_position_widget.dart';

part 'responsibilities_widget.dart';

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
    return DSResponsiveContainerWidget(
      mobileBuilder: (_) {
        return _MobileContentWidget(
          experiences: visibleItemsCount != null
              ? experiences.sublist(0, visibleItemsCount)
              : experiences,
          isVisible: isVisible,
        );
      },
      tabletBuilder: (_) {
        return _TabletContentWidget(
          experiences: visibleItemsCount != null
              ? experiences.sublist(0, visibleItemsCount)
              : experiences,
          isVisible: isVisible,
        );
      },
      desktopBuilder: (_) {
        return _DesktopContentWidget(
          experiences: experiences,
          isVisible: isVisible,
        );
      },
    );
  }
}
