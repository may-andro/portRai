import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';

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
        message: context.localizations.chatAssistantClear,
        child: DSIconButtonWidget(
          Icons.delete_outline,
          iconColor: context.colorPalette.neutral.grey9,
          buttonColor: context.colorPalette.background,
          size: DSIconButtonSize.medium,
          onPressed: () =>
              context.bloc.add(const ResetRemoteAssistantClickEvent()),
        ),
      ),
    ],
  );
}
