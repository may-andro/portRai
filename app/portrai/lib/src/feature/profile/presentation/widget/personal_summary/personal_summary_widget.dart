import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/_screen.dart';

part 'content_widget.dart';

part 'profile_image_widget.dart';

part 'details_widget.dart';

part 'backdrop_name_widget.dart';

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
    return _ContentWidget(profile: profile, isVisible: isVisible);
  }
}
