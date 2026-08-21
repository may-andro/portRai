import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/locale/presentation/route/_route.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/_bloc.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/widget/_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

class LocaleSelectionScreen extends StatelessWidget {
  const LocaleSelectionScreen({super.key, this.isDialog = false});

  final bool isDialog;

  static void navigate(BuildContext context) {
    context.isDesktop ? _showAsDialog(context) : _navigate(context);
  }

  static void _navigate(BuildContext context) {
    context.pushScreen(LocaleModuleRoute.localeSelection);
  }

  static Future<void> _showAsDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return DSDialogWidget(
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Flexible(child: LocaleSelectionScreen(isDialog: true)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DSButtonWidget(
                    label: context.localizations.close,
                    onPressed: context.popScreen,
                    variant: DSButtonVariant.secondary,
                    size: DSButtonSize.small,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return appServiceLocator.get<LocaleSelectionBloc>()
          ..add(const LoadLocaleEvent());
      },
      child: BlocConsumer<LocaleSelectionBloc, LocaleSelectionState>(
        listenWhen: (_, current) => current.isUpdatingFailed,
        listener: (context, state) {
          if (state case final LocaleSelectionState state
              when state is LocaleSelectionUpdateFailureState) {
            final message = FailureTranslator.translate(context, state.failure);
            context.showSnackBar(
              snackBar: DSSnackBar(
                message: message,
                type: DSSnackBarType.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final content = ContentWidget(isDialog: isDialog);

          if (isDialog) {
            return content;
          }

          return Scaffold(
            appBar: DSAppBarWidget(height: DSAppBarWidget.getHeight(context)),
            body: content,
          );
        },
      ),
    );
  }
}
