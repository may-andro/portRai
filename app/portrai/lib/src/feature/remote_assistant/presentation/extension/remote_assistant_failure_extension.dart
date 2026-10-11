import 'package:flutter/widgets.dart';
import 'package:portrai/generated/failure_translator.g.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/remote_assistant/domain/use_case/remote_assistant_failure.dart';
import 'package:use_case/use_case.dart';

extension RemoteAssistantFailurePresentationExtension on Failure {
  String remoteAssistantErrorText(BuildContext context) {
    final heading = FailureTranslator.translate(context, this);
    final failure = this;
    final serviceMessage = failure is RemoteAssistantFailure
        ? failure.serviceMessage
        : null;
    if (serviceMessage == null || serviceMessage.trim().isEmpty) return heading;
    return context.localizations.remoteAssistantErrorDetails(
      heading,
      serviceMessage,
    );
  }
}
