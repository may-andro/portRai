import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/assistant_screen.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/_bloc.dart';

/// Opens the assistant. It only appears once the user has enabled the
/// assistant in settings and its model is downloaded and ready.
class AssistantButton extends StatelessWidget {
  const AssistantButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssistantBloc, AssistantState>(
      buildWhen: (previous, current) =>
          previous.isEnabled != current.isEnabled ||
          previous.isModelReady != current.isModelReady,
      builder: (context, state) {
        if (!state.isEnabled || !state.isModelReady) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton(
          tooltip: context.localizations.assistantAskAi,
          onPressed: () => AssistantScreen.navigate(context),
          child: const Icon(Icons.auto_awesome),
        );
      },
    );
  }
}
