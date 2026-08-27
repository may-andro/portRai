import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/_bloc.dart';
import 'package:tracking/tracking.dart';

class ForceUpdateBottomSheetWidget extends StatelessWidget {
  const ForceUpdateBottomSheetWidget({super.key});

  static Future<void> show(
    BuildContext context, {
    required ForceUpdateBloc bloc,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: const PopScope(
            canPop: false,
            child: ForceUpdateBottomSheetWidget(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForceUpdateBloc, ForceUpdateState>(
      listenWhen: (_, current) => current is ForceUpdateLaunchFailedState,
      listener: (context, state) {
        final failure = (state as ForceUpdateLaunchFailedState).failure;
        context.showSnackBar(
          snackBar: DSSnackBar(
            message: FailureTranslator.translate(context, failure),
            type: DSSnackBarType.error,
          ),
        );
      },
      child: SafeArea(
        child: TrackingImpressionDetectorWidget(
          impressionId: 'force_update_bottom_sheet_view',
          onImpression: () {
            context.bloc.add(const BottomSheetVisibleEvent());
          },
          child: Padding(
            padding: EdgeInsets.all(context.space(factor: 3)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DSIconWidget(
                      Icons.warning_amber_rounded,
                      color: context.colorPalette.warning,
                      size: DSIconSize.medium,
                    ),
                    const DSHorizontalSpacerWidget(1),
                    Expanded(
                      child: DSTextWidget(
                        context.localizations.forceUpdateTitle,
                        style: context.typography.emphasizedTitleLarge,
                        color: context.colorPalette.neutral.grey10,
                      ),
                    ),
                  ],
                ),
                const DSVerticalSpacerWidget(1),
                DSTextWidget(
                  context.localizations.forceUpdateMessage,
                  style: context.typography.bodyLarge,
                  color: context.colorPalette.neutral.grey8,
                ),
                const DSVerticalSpacerWidget(3),
                DSButtonWidget(
                  label: context.localizations.forceUpdateButton,
                  onPressed: () {
                    context.bloc.add(const UpdateNowClickEvent());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
