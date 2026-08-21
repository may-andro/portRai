import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

part 'social_links_widget.dart';

part 'unique_proposition_widget.dart';

part 'profile_image_widget.dart';

part 'hire_button_widget.dart';

part 'elevator_pitch_widget.dart';

part 'mobile_content_widget.dart';

part 'tablet_content_widget.dart';

part 'desktop_content_widget.dart';

part 'project_years_widget.dart';

class ProfessionalSummaryWidget extends StatelessWidget {
  const ProfessionalSummaryWidget({
    super.key,
    required this.profile,
    required this.isVisible,
    required this.height,
  });

  final ProfileEntity profile;
  final bool isVisible;
  final double height;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<ProfessionalSummaryBloc>()
          ..add(LoadDataEvent(profile));
      },
      child: BlocBuilder<ProfessionalSummaryBloc, ProfessionalSummaryState>(
        builder: (context, state) {
          return _SuccessContentWidget(
            profile: profile,
            isVisible: isVisible,
            height: height,
          );
        },
      ),
    );
  }
}

class _SuccessContentWidget extends StatelessWidget {
  const _SuccessContentWidget({
    required this.profile,
    required this.isVisible,
    required this.height,
  });

  final ProfileEntity profile;
  final bool isVisible;
  final double height;

  @override
  Widget build(BuildContext context) {
    return DSResponsiveContainerWidget(
      mobileBuilder: (_) {
        return _MobileContentWidget(
          profile: profile,
          isVisible: isVisible,
          height: height,
        );
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

extension on BuildContext {
  EdgeInsets get horizontalScreenPadding => screenHorizontalPadding;
}
