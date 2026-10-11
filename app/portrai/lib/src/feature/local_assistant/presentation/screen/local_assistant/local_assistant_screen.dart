import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/presentation/route/local_assistant_module_route.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/widget/content_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/go_route/go_route_extension.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

class LocalAssistantScreen extends StatelessWidget {
  const LocalAssistantScreen({super.key});

  static void navigate(BuildContext context) {
    context.pushScreen(LocalAssistantModuleRoute.assistant);
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: appServiceLocator.get<LocalAssistantBloc>(),
    child: Builder(
      builder: (context) => RouteObserverWidget(
        onResume: () => context.bloc.add(const LocalAssistantStartedEvent()),
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.localizations.chatAssistantTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.offline_bolt_rounded),
                tooltip: context.localizations.assistantOnDeviceBadge,
                onPressed: () => _showLocalInfo(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: context.localizations.chatAssistantClear,
                onPressed: () =>
                    context.bloc.add(const ResetLocalAssistantClickEvent()),
              ),
            ],
          ),
          body: const SafeArea(child: ContentWidget()),
        ),
      ),
    ),
  );

  static Future<void> _showLocalInfo(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => DSDialogWidget(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.localizations.assistantOnDeviceTitle,
              style: Theme.of(dialogContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(context.localizations.assistantOnDeviceChatDescription),
            const SizedBox(height: 16),
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
