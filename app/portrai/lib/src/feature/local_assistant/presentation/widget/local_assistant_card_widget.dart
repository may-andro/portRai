import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

class LocalAssistantCardWidget extends StatelessWidget {
  const LocalAssistantCardWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: appServiceLocator.get<LocalAssistantBloc>(),
    child: Builder(
      builder: (context) => RouteObserverWidget(
        onResume: () =>
            context.bloc.add(const LocalAssistantInitializedEvent()),
        child: const LocalAssistantCardContentWidget(),
      ),
    ),
  );
}

class LocalAssistantCardContentWidget extends StatelessWidget {
  const LocalAssistantCardContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    return BlocBuilder<LocalAssistantBloc, LocalAssistantState>(
      builder: (context, state) {
        final progress = switch (state.status) {
          LocalAssistantDownloading(:final progress) => progress.clamp(0, 100),
          _ => 0,
        };
        final isDownloading = state.isDownloading && progress < 100;
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
                    DSIconWidget(
                      Icons.auto_awesome,
                      size: context.isMobile
                          ? DSIconSize.large
                          : DSIconSize.medium,
                      color: palette.neutral.grey1,
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
                if (state.isDownloading) ...[
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
                        onPressed: () => context.bloc.add(
                          const DisableLocalAssistantClickEvent(
                            deleteModel: true,
                          ),
                        ),
                        size: DSButtonSize.small,
                      ),
                    ],
                  ),
                ],
                if (state.isReady) ...[
                  const DSVerticalSpacerWidget(1),
                  DSTextWidget(
                    localizations.assistantSettingsReady,
                    color: palette.semantic.success,
                    style: context.typography.labelMedium,
                  ),
                ],
                if (state.hasFailed) ...[
                  const DSVerticalSpacerWidget(1),
                  DSTextWidget(
                    localizations.assistantModelError,
                    color: palette.semantic.error,
                    style: context.typography.labelMedium,
                  ),
                  DSButtonWidget(
                    label: localizations.assistantRetry,
                    onPressed: () => context.bloc.add(
                      const EnableLocalAssistantClickEvent(),
                    ),
                    size: DSButtonSize.small,
                  ),
                ],
                if (state.failure != null && !state.hasFailed) ...[
                  const DSVerticalSpacerWidget(1),
                  DSTextWidget(
                    FailureTranslator.translate(context, state.failure!),
                    color: palette.semantic.error,
                    style: context.typography.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleEnable(
    BuildContext context,
    LocalAssistantState state,
  ) async {
    final bloc = context.bloc;
    // A kept model needs no download, so no consent is required.
    if (state.isModelDownloaded) {
      bloc.add(const EnableLocalAssistantClickEvent());
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
    if (agreed ?? false) bloc.add(const EnableLocalAssistantClickEvent());
  }

  Future<void> _handleDisable(
    BuildContext context,
    LocalAssistantState state,
  ) async {
    final bloc = context.bloc;
    if (!state.isReady) {
      // Cancelling a download, or clearing a failed attempt, leaves no model
      // worth keeping.
      bloc.add(const DisableLocalAssistantClickEvent(deleteModel: true));
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
      bloc.add(DisableLocalAssistantClickEvent(deleteModel: deleteModel));
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
