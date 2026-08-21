import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Error Card', type: DSErrorCardWidget)
Widget buildErrorCard(BuildContext context) {
  final message = context.knobs.stringOrNull(
    label: 'Message',
    initialValue: null,
  );

  final hasRetry = context.knobs.boolean(
    label: 'Has Retry Button',
    initialValue: false,
  );

  final errorTypes = [
    ('Default Error', 'Something went wrong, please try later'),
    (
      'Network Error',
      'No internet connection. Please check your network settings and try again.',
    ),
    ('Server Error', 'Unable to connect to server. Please try again later.'),
    ('Not Found', 'The requested resource was not found.'),
    (
      'Permission Denied',
      'You don\'t have permission to access this resource.',
    ),
  ];

  final showQuickOptions = context.knobs.boolean(
    label: 'Show Quick Options',
    initialValue: false,
  );

  if (showQuickOptions) {
    final selectedError = context.knobs.object.dropdown(
      label: 'Error Type',
      options: errorTypes.map((e) => e.$2).toList(),
      labelBuilder: (msg) => errorTypes.firstWhere((e) => e.$2 == msg).$1,
    );

    return Center(
      child: DSErrorCardWidget(
        message: selectedError,
        onRetryClicked: hasRetry ? () {} : null,
      ),
    );
  }

  return Center(
    child: DSErrorCardWidget(
      message: message,
      onRetryClicked: hasRetry ? () {} : null,
    ),
  );
}
