import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

class DSErrorCardWidget extends StatelessWidget {
  const DSErrorCardWidget({
    super.key,
    this.message,
    this.onRetryClicked,
    this.title = 'Oops…',
    this.retryLabel = 'Retry',
  });

  final VoidCallback? onRetryClicked;
  final String? message;

  /// Heading above [message]; pass a translated one where available.
  final String title;

  /// Label of the retry button shown when [onRetryClicked] is given.
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.space(factor: 3)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.error,
            size: context.space(factor: 10),
            color: context.colorPalette.brand.primary.color,
          ),
          const DSVerticalSpacerWidget(2),
          Flexible(
            child: DSTextWidget(
              title,
              style: context.typography.headlineMedium,
              color: context.colorPalette.neutral.grey9,
            ),
          ),
          const DSVerticalSpacerWidget(1),
          Flexible(
            child: DSTextWidget(
              message ?? 'Something went wrong, please try later',
              style: context.typography.bodyLarge,
              color: context.colorPalette.neutral.grey7,
            ),
          ),
          const DSVerticalSpacerWidget(2),
          if (onRetryClicked != null) ...[
            FittedBox(
              child: DSButtonWidget(
                label: retryLabel,
                onPressed: onRetryClicked!,
                variant: DSButtonVariant.secondary,
                size: DSButtonSize.small,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
