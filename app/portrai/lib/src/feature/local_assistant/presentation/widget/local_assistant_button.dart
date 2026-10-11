import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/local_assistant_screen.dart';

/// Opens the assistant. It only appears once the user has enabled the
/// assistant in settings and its model is downloaded and ready.
class LocalAssistantButton extends StatelessWidget {
  const LocalAssistantButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalAssistantBloc, LocalAssistantState>(
      buildWhen: (previous, current) => previous.isReady != current.isReady,
      builder: (context, state) {
        if (!state.isReady) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton(
          tooltip: context.localizations.assistantAskAi,
          onPressed: () => LocalAssistantScreen.navigate(context),
          child: const Icon(Icons.auto_awesome),
        );
      },
    );
  }
}
