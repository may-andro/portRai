import 'dart:math';

import 'package:collection/collection.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/ai_image_gen/ai_image_gen.dart';
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

part 'project_backdrop_widget.dart';

part 'identity_widget.dart';

part 'variant/professional_summary_variant.dart';

part 'variant/overview_professional_summary.dart';

part 'variant/engineering_professional_summary.dart';

part 'variant/hiring_professional_summary.dart';

part 'component/code_card_widget.dart';

part 'component/availability_card_widget.dart';

part 'component/blueprint_grid_widget.dart';

class ProfessionalSummaryWidget extends StatelessWidget {
  const ProfessionalSummaryWidget({
    super.key,
    required this.profile,
    required this.isVisible,
    required this.height,
    this.projectImages = const [],
    this.variant = const OverviewProfessionalSummary(),
  });

  final ProfileEntity profile;
  final bool isVisible;
  final double height;
  final List<String> projectImages;

  final ProfessionalSummaryVariant variant;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return appServiceLocator.get<ProfessionalSummaryBloc>()
          ..add(LoadDataEvent(profile));
      },
      child: Builder(
        builder: (context) {
          return _SuccessContentWidget(
            profile: profile,
            variant: variant,
            isVisible: isVisible,
            height: height,
            projectImages: projectImages,
          );
        },
      ),
    );
  }
}

class _SuccessContentWidget extends StatelessWidget {
  const _SuccessContentWidget({
    required this.profile,
    required this.variant,
    required this.isVisible,
    required this.height,
    required this.projectImages,
  });

  final ProfileEntity profile;
  final ProfessionalSummaryVariant variant;
  final bool isVisible;
  final double height;
  final List<String> projectImages;

  @override
  Widget build(BuildContext context) {
    final responsiveContent = DSResponsiveContainerWidget(
      mobileBuilder: (_) {
        return _MobileContentWidget(
          profile: profile,
          variant: variant,
          isVisible: isVisible,
          height: height,
        );
      },
      tabletBuilder: (_) {
        return _TabletContentWidget(
          profile: profile,
          variant: variant,
          isVisible: isVisible,
        );
      },
      desktopBuilder: (_) {
        return _DesktopContentWidget(
          profile: profile,
          variant: variant,
          isVisible: isVisible,
        );
      },
    );

    return Stack(
      children: [
        Positioned.fill(
          child: variant.buildBackdrop(
            context,
            isVisible: isVisible,
            projectImages: projectImages,
          ),
        ),
        responsiveContent,
      ],
    );
  }
}

extension on BuildContext {
  EdgeInsets get horizontalScreenPadding => screenHorizontalPadding;
}
