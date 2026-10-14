import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/app/restart_app.dart';
import 'package:portrai/src/feature/design_system/presentation/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

part 'restart_app_tile_widget.dart';

class DesignSystemSelectorWidget extends StatelessWidget {
  const DesignSystemSelectorWidget({super.key, this.onRestart = restartApp});

  final Future<void> Function() onRestart;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          appServiceLocator.get<DesignSystemBloc>()
            ..add(const LoadDesignSystemEvent()),
      child: _SelectorWidget(onRestart: onRestart),
    );
  }
}

class _SelectorWidget extends StatelessWidget {
  const _SelectorWidget({required this.onRestart});

  final Future<void> Function() onRestart;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DesignSystemBloc, DesignSystemState>(
      listenWhen: (previous, current) =>
          current.failure != null || current.shouldRestartApp,
      listener: (context, state) async {
        if (state.shouldRestartApp) {
          await onRestart();
          return;
        }
        final failure = state.failure;
        if (failure != null) {
          context.showSnackBar(
            snackBar: DSSnackBar(
              message: FailureTranslator.translate(context, failure),
              type: DSSnackBarType.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final canReset =
            state.isLoaded &&
            state.designSystem != null &&
            !state.shouldRestartApp;
        final resetColor = canReset
            ? context.colorPalette.neutral.grey9
            : context.colorPalette.neutral.grey5;
        return DSCardWidget(
          child: Column(
            children: [
              ListTile(
                leading: DSIconWidget(
                  Icons.palette_outlined,
                  color: context.colorPalette.neutral.grey9,
                  size: DSIconSize.medium,
                ),
                title: DSTextWidget(
                  context.localizations.developerMenuDesignSystemPicker,
                  style: context.typography.emphasizedBodyMedium,
                  color: context.colorPalette.neutral.grey9,
                ),
                subtitle: DSTextWidget(
                  context
                      .localizations
                      .developerMenuDesignSystemPickerDescription,
                  style: context.typography.emphasizedBodySmall,
                  color: context.colorPalette.neutral.grey9,
                ),
                trailing: DropdownButton<DesignSystem>(
                  value: state.designSystem,
                  hint: DSTextWidget(
                    context.localizations.developerMenuDesignSystemAutomatic,
                    style: context.typography.bodySmall,
                    color: context.colorPalette.neutral.grey9,
                  ),
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final designSystem in DesignSystem.values)
                      DropdownMenuItem(
                        value: designSystem,
                        child: DSTextWidget(
                          designSystem.name,
                          style: context.typography.bodySmall,
                          color: context.colorPalette.neutral.grey9,
                        ),
                      ),
                  ],
                  onChanged: !state.isLoaded
                      ? null
                      : (designSystem) {
                          if (designSystem != null) {
                            context.bloc.add(
                              DesignSystemClickEvent(designSystem),
                            );
                          }
                        },
                ),
              ),
              DSHorizontalDividerWidget(
                thickness: 1,
                color: context.colorPalette.neutral.grey3,
              ),
              ListTile(
                enabled: canReset,
                leading: DSIconWidget(
                  Icons.restart_alt_outlined,
                  color: resetColor,
                  size: DSIconSize.medium,
                ),
                title: DSTextWidget(
                  context.localizations.developerMenuDesignSystemReset,
                  style: context.typography.emphasizedBodyMedium,
                  color: resetColor,
                ),
                subtitle: DSTextWidget(
                  context
                      .localizations
                      .developerMenuDesignSystemResetDescription,
                  style: context.typography.emphasizedBodySmall,
                  color: resetColor,
                ),
                onTap: !canReset
                    ? null
                    : () =>
                          context.bloc.add(const DesignSystemResetClickEvent()),
              ),
              _RestartAppTileWidget(
                isRestartRequired: state.isRestartRequired,
                onRestart: onRestart,
              ),
            ],
          ),
        );
      },
    );
  }
}
