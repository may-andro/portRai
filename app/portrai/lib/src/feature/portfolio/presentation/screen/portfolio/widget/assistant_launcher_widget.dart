import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';

/// App composition keeps provider selection out of the shared assistant.
class AssistantLauncherWidget extends StatelessWidget {
  const AssistantLauncherWidget({
    super.key,
    this.onLocalSelected,
    this.onRemoteSelected,
  });

  final VoidCallback? onLocalSelected;
  final VoidCallback? onRemoteSelected;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<LocalAssistantBloc, LocalAssistantState>(
    builder: (context, local) =>
        BlocBuilder<RemoteAssistantBloc, RemoteAssistantState>(
          builder: (context, remote) {
            final localOffered =
                context.read<LocalAssistantBloc>().isPlatformSupported &&
                local.isAvailable;
            final remoteOffered =
                context.read<RemoteAssistantBloc>().isPlatformSupported &&
                remote.status != RemoteAssistantStatus.loading &&
                remote.status != RemoteAssistantStatus.unavailable;
            if (!localOffered && !remoteOffered) return const SizedBox.shrink();
            return FloatingActionButton(
              tooltip: context.localizations.assistantAskAi,
              onPressed: () async {
                bool? chooseLocal;
                if (localOffered && remoteOffered) {
                  chooseLocal = await showModalBottomSheet<bool>(
                    context: context,
                    showDragHandle: true,
                    builder: (sheetContext) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(context.localizations.assistantChooseTitle),
                          ListTile(
                            leading: const Icon(Icons.offline_bolt_outlined),
                            title: Text(
                              context.localizations.assistantChooseLocal,
                            ),
                            onTap: () => Navigator.of(sheetContext).pop(true),
                          ),
                          ListTile(
                            leading: const Icon(Icons.cloud_outlined),
                            title: Text(
                              context.localizations.assistantChooseCloud,
                            ),
                            onTap: () => Navigator.of(sheetContext).pop(false),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  chooseLocal = localOffered;
                }
                if (chooseLocal == null || !context.mounted) return;
                context.bloc.add(
                  AssistantSelectionClickEvent(isLocal: chooseLocal),
                );
                if (chooseLocal) {
                  (onLocalSelected ??
                      () => LocalAssistantScreen.navigate(context))();
                } else {
                  (onRemoteSelected ??
                      () => RemoteAssistantScreen.navigate(context))();
                }
              },
              child: const Icon(Icons.auto_awesome),
            );
          },
        ),
  );
}
