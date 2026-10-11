import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/remote_assistant_screen.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

class RemoteAssistantCardWidget extends StatelessWidget {
  const RemoteAssistantCardWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: appServiceLocator.get<RemoteAssistantBloc>(),
    child: Builder(
      builder: (context) => RouteObserverWidget(
        onResume: () =>
            context.bloc.add(const RemoteAssistantInitializedEvent()),
        child: const _CardContentWidget(),
      ),
    ),
  );
}

class _CardContentWidget extends StatelessWidget {
  const _CardContentWidget();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RemoteAssistantBloc, RemoteAssistantState>(
        builder: (context, state) {
          if (!context.bloc.isPlatformSupported ||
              state.status == RemoteAssistantStatus.loading ||
              state.status == RemoteAssistantStatus.unavailable) {
            return const SizedBox.shrink();
          }
          final localizations = context.localizations;
          final palette = context.colorPalette;
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
                        Icons.cloud_outlined,
                        color: palette.neutral.grey1.color,
                      ),
                      const DSHorizontalSpacerWidget(2),
                      Expanded(
                        child: DSTextWidget(
                          localizations.remoteAssistantSettingsTitle,
                          color: palette.neutral.grey1,
                          style: context.typography.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const DSVerticalSpacerWidget(1),
                  DSTextWidget(
                    localizations.remoteAssistantDisclosure,
                    color: palette.neutral.grey3,
                    style: context.typography.bodyMedium,
                  ),
                  if (state.failure != null) ...[
                    const DSVerticalSpacerWidget(1),
                    DSTextWidget(
                      FailureTranslator.translate(context, state.failure!),
                      color: palette.semantic.error,
                      style: context.typography.bodyMedium,
                    ),
                  ],
                  if (state.isReady)
                    TextButton(
                      onPressed: () => context.bloc.add(
                        const ResetRemoteAssistantClickEvent(),
                      ),
                      child: Text(localizations.remoteAssistantReset),
                    ),
                  TextButton(
                    onPressed: () => RemoteAssistantScreen.navigate(context),
                    child: Text(localizations.assistantAskAi),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
