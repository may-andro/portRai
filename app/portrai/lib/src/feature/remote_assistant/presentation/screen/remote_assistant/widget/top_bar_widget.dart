import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/widget/page_app_bar_widget.dart';

/// The page header of the chat, with its actions.
class TopBarWidget extends StatelessWidget {
  const TopBarWidget({super.key});

  @override
  Widget build(BuildContext context) => PageTopBarWidget(
    title: context.localizations.chatAssistantTitle,
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
