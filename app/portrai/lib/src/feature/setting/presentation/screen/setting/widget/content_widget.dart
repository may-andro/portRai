import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/developer_menu_screen.dart';
import 'package:portrai/src/feature/job_opening/job_opening.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/language_card_widget.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/role_card_widget.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/section_title_widget.dart';
import 'package:portrai/src/widget/app_version_widget.dart';

/// The settings form as a sliver that fills the remaining height, keeping the
/// app version at the bottom.
class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key, required this.state});

  final SettingLoadedState state;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: context.screenHorizontalPadding.copyWith(
          top: context.space(factor: context.isDesktop ? 2 : 0),
          bottom: context.space(factor: context.isDesktop ? 2 : 0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isLanguageSelectorEnabled) ...[
              SectionTitleWidget(title: context.localizations.language),
              const LanguageCardWidget(),
            ],
            if (state.userRole case final userRole?) ...[
              SectionTitleWidget(
                title: context.localizations.settingRoleSection,
              ),
              RoleCardWidget(role: userRole),
            ],
            if (state.isNotificationSettingAvailable) ...[
              SectionTitleWidget(
                title: context.localizations.settingNotificationSection,
              ),
              const NotificationPermissionCardWidget(),
            ],
            if (state.isLocalAssistantAvailable) ...[
              SectionTitleWidget(title: context.localizations.assistantTitle),
              const LocalAssistantCardWidget(),
            ],
            if (state.isJobOpeningsEnabled) ...[
              SectionTitleWidget(
                title: context.localizations.jobOpeningsSection,
              ),
              const JobOpeningsCardWidget(),
            ],
            if (state.isDevMenuEnabled) ...[
              const DSVerticalSpacerWidget(3),
              DSButtonWidget(
                label: context.localizations.settingDeveloperMode,
                onPressed: () => DeveloperMenuScreen.navigate(context),
                variant: DSButtonVariant.text,
                size: DSButtonSize.small,
              ),
            ],
            const Spacer(),
            const DSVerticalSpacerWidget(3),
            const SafeArea(child: Align(child: AppVersionWidget())),
            const DSVerticalSpacerWidget(2),
          ],
        ),
      ),
    );
  }
}
