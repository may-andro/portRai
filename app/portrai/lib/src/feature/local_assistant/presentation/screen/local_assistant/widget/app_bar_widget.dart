import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: DSTextWidget(
      context.localizations.chatAssistantTitle,
      color: context.colorPalette.neutral.grey9,
      style: context.typography.emphasizedTitleMedium,
    ),
    actions: [
      Tooltip(
        message: context.localizations.assistantOnDeviceBadge,
        child: DSIconButtonWidget(
          Icons.offline_bolt_rounded,
          iconColor: context.colorPalette.neutral.grey9,
          buttonColor: context.colorPalette.background,
          size: DSIconButtonSize.medium,
          onPressed: () => _showLocalInfo(context),
        ),
      ),
      Tooltip(
        message: context.localizations.chatAssistantClear,
        child: DSIconButtonWidget(
          Icons.delete_outline,
          iconColor: context.colorPalette.neutral.grey9,
          buttonColor: context.colorPalette.background,
          size: DSIconButtonSize.medium,
          onPressed: () =>
              context.bloc.add(const ResetLocalAssistantClickEvent()),
        ),
      ),
    ],
  );

  static Future<void> _showLocalInfo(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => DSDialogWidget(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DSTextWidget(
              context.localizations.assistantOnDeviceTitle,
              color: dialogContext.colorPalette.neutral.grey9,
              style: dialogContext.typography.emphasizedTitleLarge,
            ),
            const DSVerticalSpacerWidget(2),
            DSTextWidget(
              context.localizations.assistantOnDeviceChatDescription,
              color: dialogContext.colorPalette.surface.onSurface,
              style: dialogContext.typography.bodyMedium,
            ),
            const DSVerticalSpacerWidget(2),
            Align(
              alignment: Alignment.centerRight,
              child: DSButtonWidget(
                label: context.localizations.close,
                onPressed: () => Navigator.of(dialogContext).pop(),
                variant: DSButtonVariant.secondary,
                size: DSButtonSize.small,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
