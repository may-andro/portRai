import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';

class AssistantCardWidget extends StatelessWidget {
  const AssistantCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    return BlocBuilder<AssistantBloc, AssistantState>(
      builder: (context, state) {
        final progress = state.downloadProgress.clamp(0, 100);
        final isDownloading = state.isPreparingModel && progress < 100;
        final failed =
            state.isEnabled && !state.isPreparingModel && state.hasError;
        return DSCardWidget(
          backgroundColor: palette.inverseSurface,
          radius: context.dimen.radiusLevel2,
          elevation: context.dimen.elevationLevel1,
          margin: EdgeInsets.only(bottom: context.space(factor: 2)),
          child: Padding(
            padding: EdgeInsets.all(context.space(factor: 2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: context.iconSize,
                      color: palette.neutral.grey1.color,
                    ),
                    const DSHorizontalSpacerWidget(2),
                    Expanded(
                      child: DSTextWidget(
                        localizations.assistantSettingsToggleTitle,
                        color: palette.neutral.grey1,
                        style: context.typography.titleMedium,
                      ),
                    ),
                    Switch(
                      value: state.isEnabled,
                      onChanged: (enabled) => enabled
                          ? _handleEnable(context, state)
                          : _handleDisable(context, state),
                    ),
                  ],
                ),
                const DSVerticalSpacerWidget(1),
                DSTextWidget(
                  localizations.assistantSettingsDescription,
                  color: palette.neutral.grey3,
                  style: context.typography.bodyMedium,
                ),
                if (state.isPreparingModel) ...[
                  const DSVerticalSpacerWidget(2),
                  LinearProgressIndicator(
                    color: palette.brand.primary.color,
                    value: isDownloading ? progress / 100 : null,
                  ),
                  const DSVerticalSpacerWidget(1),
                  Row(
                    children: [
                      Expanded(
                        child: DSTextWidget(
                          isDownloading
                              ? localizations.assistantDownloadProgress(
                                  progress,
                                )
                              : localizations.assistantPreparingModel,
                          color: palette.neutral.grey3,
                          style: context.typography.labelMedium,
                        ),
                      ),
                      DSButtonWidget(
                        label: localizations.assistantCancel,
                        onPressed: () => context.read<AssistantBloc>().add(
                          const DisableAssistantClickEvent(deleteModel: true),
                        ),
                        variant: DSButtonVariant.primary,
                        size: DSButtonSize.small,
                      ),
                    ],
                  ),
                ],
                if (state.isEnabled && state.isModelReady) ...[
                  const DSVerticalSpacerWidget(1),
                  DSTextWidget(
                    localizations.assistantSettingsReady,
                    color: palette.semantic.success,
                    style: context.typography.labelMedium,
                  ),
                ],
                if (failed) ...[
                  const DSVerticalSpacerWidget(1),
                  DSTextWidget(
                    localizations.assistantModelError,
                    color: palette.semantic.error,
                    style: context.typography.labelMedium,
                  ),
                  DSButtonWidget(
                    label: localizations.assistantRetry,
                    onPressed: () => context.read<AssistantBloc>().add(
                      const EnableAssistantClickEvent(),
                    ),
                    variant: DSButtonVariant.primary,
                    size: DSButtonSize.small,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleEnable(BuildContext context, AssistantState state) async {
    final bloc = context.read<AssistantBloc>();
    // A kept model needs no download, so no consent is required.
    if (state.isModelDownloaded) {
      bloc.add(const EnableAssistantClickEvent());
      return;
    }
    final localizations = context.localizations;
    final agreed = await _showChoiceSheet<bool>(
      context,
      title: localizations.assistantEnableDialogTitle,
      message: localizations.assistantEnableDialogMessage,
      choices: [
        (localizations.assistantCancel, false),
        (localizations.assistantEnableDialogConfirm, true),
      ],
    );
    if (agreed ?? false) bloc.add(const EnableAssistantClickEvent());
  }

  Future<void> _handleDisable(
    BuildContext context,
    AssistantState state,
  ) async {
    final bloc = context.read<AssistantBloc>();
    if (!state.isModelReady) {
      // Cancelling a download, or clearing a failed attempt, leaves no model
      // worth keeping.
      bloc.add(const DisableAssistantClickEvent(deleteModel: true));
      return;
    }
    final localizations = context.localizations;
    final deleteModel = await _showChoiceSheet<bool>(
      context,
      title: localizations.assistantDisableDialogTitle,
      message: localizations.assistantDisableDialogMessage,
      choices: [
        (localizations.assistantDisableDialogKeep, false),
        (localizations.assistantDisableDialogDelete, true),
      ],
    );
    if (deleteModel != null) {
      bloc.add(DisableAssistantClickEvent(deleteModel: deleteModel));
    }
  }

  Future<T?> _showChoiceSheet<T>(
    BuildContext context, {
    required String title,
    required String message,
    required List<(String, T)> choices,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            sheetContext.space(factor: 3),
            0,
            sheetContext.space(factor: 3),
            sheetContext.space(factor: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSTextWidget(
                title,
                color: sheetContext.colorPalette.neutral.grey9,
                style: sheetContext.typography.emphasizedTitleMedium,
              ),
              const DSVerticalSpacerWidget(1),
              DSTextWidget(
                message,
                color: sheetContext.colorPalette.neutral.grey7,
                style: sheetContext.typography.bodyMedium,
              ),
              const DSVerticalSpacerWidget(2),
              Row(
                children: [
                  for (final (index, (label, value)) in choices.indexed) ...[
                    if (index > 0) const DSHorizontalSpacerWidget(1),
                    Expanded(
                      child: DSButtonWidget(
                        label: label,
                        onPressed: () => Navigator.of(sheetContext).pop(value),
                        variant: index == choices.length - 1
                            ? DSButtonVariant.primary
                            : DSButtonVariant.secondary,
                        size: DSButtonSize.small,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
