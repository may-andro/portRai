import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';

class AssistantLauncherWidget extends StatelessWidget {
  const AssistantLauncherWidget({
    super.key,
    this.onLocalLaunch,
    this.onRemoteLaunch,
  });

  final VoidCallback? onLocalLaunch;
  final VoidCallback? onRemoteLaunch;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<PortfolioBloc, PortfolioState>(
    builder: (context, state) {
      if (state is! LoadedState ||
          (!state.isLocalAssistantAvailable &&
              !state.isRemoteAssistantAvailable)) {
        return const SizedBox.shrink();
      }
      final isLocal =
          !state.isRemoteAssistantAvailable && state.isLocalAssistantAvailable;
      return FloatingActionButton(
        tooltip: context.localizations.assistantAskAi,
        onPressed: () {
          context.bloc.add(AssistantLaunchClickEvent(isLocal: isLocal));
          if (isLocal) {
            (onLocalLaunch ?? () => LocalAssistantScreen.navigate(context))();
          } else {
            (onRemoteLaunch ?? () => RemoteAssistantScreen.navigate(context))();
          }
        },
        child: const Icon(Icons.auto_awesome),
      );
    },
  );
}
