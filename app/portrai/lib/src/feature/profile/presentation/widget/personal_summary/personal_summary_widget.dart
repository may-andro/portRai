import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

part 'content_widget.dart';

part 'profile_image_widget.dart';

part 'details_widget.dart';

part 'backdrop_name_widget.dart';

class PersonalSummaryWidget extends StatelessWidget {
  const PersonalSummaryWidget({
    super.key,
    required this.profile,
    required this.isVisible,
    required this.onViewProfileClicked,
  });

  final ProfileEntity profile;
  final bool isVisible;

  /// Called when the view full profile button is tapped. The caller decides
  /// what the tap does, such as opening the profile.
  final VoidCallback onViewProfileClicked;

  @override
  Widget build(BuildContext context) {
    return _ContentWidget(
      profile: profile,
      isVisible: isVisible,
      onViewProfileClicked: onViewProfileClicked,
    );
  }
}
