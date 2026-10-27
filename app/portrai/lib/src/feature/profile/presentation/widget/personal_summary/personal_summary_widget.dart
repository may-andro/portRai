import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/profile_screen.dart';
import 'package:portrai/src/feature/profile/presentation/widget/personal_summary/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

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
    return BlocProvider(
      create: (_) => appServiceLocator.get<PersonalSummaryBloc>(),
      child: _ContentWidget(profile: profile, isVisible: isVisible),
    );
  }
}
