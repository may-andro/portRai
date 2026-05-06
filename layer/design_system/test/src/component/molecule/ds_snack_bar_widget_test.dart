import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSSnackBar',
    (theme) => [
      TestCase(
        'success',
        _SnackBarPreview(
          type: DSSnackBarType.success,
          message: 'Changes saved successfully.',
          theme: theme,
        ),
      ),
      TestCase(
        'error',
        _SnackBarPreview(
          type: DSSnackBarType.error,
          message: 'Something went wrong. Please retry.',
          theme: theme,
        ),
      ),
      TestCase(
        'info',
        _SnackBarPreview(
          type: DSSnackBarType.info,
          message: 'Your session will expire in 5 minutes.',
          theme: theme,
        ),
      ),
    ],
  );
}

/// Visual preview of a snackbar content since [DSSnackBar] is a data class
/// and its content widget is private.
class _SnackBarPreview extends StatelessWidget {
  const _SnackBarPreview({
    required this.type,
    required this.message,
    required this.theme,
  });

  final DSSnackBarType type;
  final String message;
  final DSTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: type.getBackgroundColor(context).color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel1.value),
      ),
      child: DSTextWidget(
        message,
        style: context.typography.bodyMedium,
        color: type.getTextColor(context),
      ),
    );
  }
}
