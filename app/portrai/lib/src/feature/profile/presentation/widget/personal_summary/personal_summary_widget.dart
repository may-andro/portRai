import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/_screen.dart';

part 'intro_widget.dart';

part 'summary_widget.dart';

part 'education_widget.dart';

part 'profile_image_widget.dart';

part 'mobile_content_widget.dart';

part 'tablet_content_widget.dart';

part 'desktop_content_widget.dart';

part 'detail_button_widget.dart';

part 'right_card_widget.dart';

part 'left_card_widget.dart';

class PersonalSummaryWidget extends StatelessWidget {
  const PersonalSummaryWidget({
    super.key,
    required this.profile,
    required this.isVisible,
  });

  final ProfileEntity profile;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return DSResponsiveContainerWidget(
      mobileBuilder: (_) {
        return _MobileContentWidget(profile: profile, isVisible: isVisible);
      },
      tabletBuilder: (_) {
        return _TabletContentWidget(profile: profile, isVisible: isVisible);
      },
      desktopBuilder: (_) {
        return _DesktopContentWidget(profile: profile, isVisible: isVisible);
      },
    );
  }
}
