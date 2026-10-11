import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';

/// App composition keeps independent assistant entry points out of shared UI.
class AssistantLauncherWidget extends StatelessWidget {
  const AssistantLauncherWidget({
    super.key,
    this.onLocalLaunch,
    this.onRemoteLaunch,
  });

  final VoidCallback? onLocalLaunch;
  final VoidCallback? onRemoteLaunch;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LocalAssistantBloc, LocalAssistantState>(
        builder: (context, local) =>
            BlocBuilder<RemoteAssistantBloc, RemoteAssistantState>(
              builder: (context, remote) {
                final localOffered =
                    !remote.isFeatureEnabled &&
                    remote.status != RemoteAssistantStatus.loading &&
                    context.read<LocalAssistantBloc>().isPlatformSupported &&
                    local.isAvailable;
                final remoteOffered =
                    remote.isFeatureEnabled &&
                    context.read<RemoteAssistantBloc>().isPlatformSupported &&
                    remote.status != RemoteAssistantStatus.loading &&
                    remote.status != RemoteAssistantStatus.unavailable;
                if (!localOffered && !remoteOffered) {
                  return const SizedBox.shrink();
                }
                return FloatingActionButton(
                  tooltip: context.localizations.assistantAskAi,
                  onPressed: () {
                    context.bloc.add(
                      AssistantLaunchClickEvent(isLocal: localOffered),
                    );
                    if (localOffered) {
                      (onLocalLaunch ??
                          () => LocalAssistantScreen.navigate(context))();
                    } else {
                      (onRemoteLaunch ??
                          () => RemoteAssistantScreen.navigate(context))();
                    }
                  },
                  child: const Icon(Icons.auto_awesome),
                );
              },
            ),
      );
}
