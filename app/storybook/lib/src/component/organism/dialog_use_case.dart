import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Dialog - Simple', type: DSDialogWidget)
Widget buildDialogSimple(BuildContext context) {
  // Capture theme values before dialog
  final grey9 = context.colorPalette.neutral.grey9;
  final grey7 = context.colorPalette.neutral.grey7;
  final headlineSmall = context.typography.headlineSmall;
  final bodyMedium = context.typography.bodyMedium;

  return Center(
    child: DSButtonWidget(
      label: 'Show Dialog',
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogContext) => DSDialogWidget(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSTextWidget('Welcome!', color: grey9, style: headlineSmall),
                DSVerticalSpacerWidget(1),
                DSTextWidget(
                  'This is a simple dialog widget example.',
                  color: grey7,
                  style: bodyMedium,
                  textAlign: TextAlign.center,
                ),
                DSVerticalSpacerWidget(2),
                DSButtonWidget(
                  label: 'Close',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  variant: DSButtonVariant.primary,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

@UseCase(name: 'Dialog - Confirmation', type: DSDialogWidget)
Widget buildDialogConfirmation(BuildContext context) {
  // Capture theme values before dialog
  final warning = context.colorPalette.semantic.warning;
  final grey9 = context.colorPalette.neutral.grey9;
  final grey7 = context.colorPalette.neutral.grey7;
  final headlineSmall = context.typography.headlineSmall;
  final bodyMedium = context.typography.bodyMedium;

  return Center(
    child: DSButtonWidget(
      label: 'Delete Item',
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogContext) => DSDialogWidget(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSIconWidget(
                  Icons.warning_amber_rounded,
                  color: warning,
                  size: DSIconSize.large,
                ),
                DSVerticalSpacerWidget(1),
                DSTextWidget(
                  'Confirm Delete',
                  color: grey9,
                  style: headlineSmall,
                ),
                DSVerticalSpacerWidget(1),
                DSTextWidget(
                  'Are you sure you want to delete this item? This action cannot be undone.',
                  color: grey7,
                  style: bodyMedium,
                  textAlign: TextAlign.center,
                ),
                DSVerticalSpacerWidget(2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: DSButtonWidget(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        variant: DSButtonVariant.secondary,
                      ),
                    ),
                    DSHorizontalSpacerWidget(1),
                    Expanded(
                      child: DSButtonWidget(
                        label: 'Delete',
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        variant: DSButtonVariant.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      variant: DSButtonVariant.error,
    ),
  );
}

@UseCase(name: 'Dialog - Form', type: DSDialogWidget)
Widget buildDialogForm(BuildContext context) {
  // Capture theme values before dialog
  final grey9 = context.colorPalette.neutral.grey9;
  final headlineSmall = context.typography.headlineSmall;

  return Center(
    child: DSButtonWidget(
      label: 'Add New Item',
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogContext) => DSDialogWidget(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSTextWidget(
                  'Add New Task',
                  color: grey9,
                  style: headlineSmall,
                ),
                DSVerticalSpacerWidget(1),
                DSTextFieldWidget(
                  labelText: 'Task Name',
                  hintText: 'Enter task name',
                ),
                DSVerticalSpacerWidget(1),
                DSTextFieldWidget(
                  labelText: 'Description',
                  hintText: 'Enter description',
                  maxLines: 3,
                ),
                DSVerticalSpacerWidget(2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DSButtonWidget(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      variant: DSButtonVariant.text,
                      size: DSButtonSize.small,
                    ),
                    DSHorizontalSpacerWidget(0.5),
                    DSButtonWidget(
                      label: 'Add',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      variant: DSButtonVariant.primary,
                      size: DSButtonSize.small,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

@UseCase(name: 'Dialog - Success', type: DSDialogWidget)
Widget buildDialogSuccess(BuildContext context) {
  // Capture theme values before dialog
  final success = context.colorPalette.semantic.success;
  final grey9 = context.colorPalette.neutral.grey9;
  final grey7 = context.colorPalette.neutral.grey7;
  final headlineSmall = context.typography.headlineSmall;
  final bodyMedium = context.typography.bodyMedium;

  return Center(
    child: DSButtonWidget(
      label: 'Complete Action',
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogContext) => DSDialogWidget(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSIconWidget(
                  Icons.check_circle_rounded,
                  color: success,
                  size: DSIconSize.large,
                ),
                DSVerticalSpacerWidget(1),
                DSTextWidget('Success!', color: grey9, style: headlineSmall),
                DSVerticalSpacerWidget(1),
                DSTextWidget(
                  'Your action was completed successfully.',
                  color: grey7,
                  style: bodyMedium,
                  textAlign: TextAlign.center,
                ),
                DSVerticalSpacerWidget(2),
                DSButtonWidget(
                  label: 'Done',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  variant: DSButtonVariant.primary,
                ),
              ],
            ),
          ),
        );
      },
      variant: DSButtonVariant.secondary,
    ),
  );
}
