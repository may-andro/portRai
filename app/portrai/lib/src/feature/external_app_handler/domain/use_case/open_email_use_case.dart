import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';
import 'package:open_mail/open_mail.dart';
import 'package:portrai/src/feature/external_app_handler/domain/use_case/open_external_url_use_case.dart';
import 'package:use_case/use_case.dart';

sealed class OpenEmailFailure extends BasicFailure {
  const OpenEmailFailure({super.cause});
}

@Localizable('errorNoEmailAppFound')
class NoEmailAppFoundFailure extends OpenEmailFailure {
  const NoEmailAppFoundFailure({super.cause});
}

@Localizable('errorWebEmailLaunch')
class WebEmailLaunchFailure extends OpenEmailFailure {
  const WebEmailLaunchFailure({super.cause});
}

@Localizable('errorEmailLaunch')
class EmailLaunchFailure extends OpenEmailFailure {
  const EmailLaunchFailure({super.cause});
}

@register
class OpenEmailUseCase extends BaseUseCase<bool, String, OpenEmailFailure> {
  OpenEmailUseCase(this._openExternalUrlUseCase);

  final OpenExternalUrlUseCase _openExternalUrlUseCase;

  @visibleForTesting
  bool get isWeb => kIsWeb;

  @visibleForTesting
  Future<OpenMailAppResult> composeEmail(String input) {
    return OpenMail.composeNewEmailInMailApp(
      emailContent: EmailContent(
        to: [input],
        subject: emailSubject,
        body: emailBody,
      ),
    );
  }

  @visibleForTesting
  static const emailSubject = 'Virtual Call Opportunity';

  @visibleForTesting
  static const emailBody =
      'Hello,\n\nI would like to arrange a virtual call to get in touch with you regarding an exciting opportunity.\n\nThank you!';

  @protected
  @override
  FutureOr<Either<OpenEmailFailure, bool>> execute(String input) async {
    if (isWeb) {
      final String encodedSubject = Uri.encodeComponent(emailSubject);
      final String encodedBody = Uri.encodeComponent(emailBody);
      final String mailtoUrl =
          'mailto:$input?subject=$encodedSubject&body=$encodedBody';
      final Uri mailUri = Uri.parse(mailtoUrl);

      final result = await _openExternalUrlUseCase(
        OpenExternalUrlParam(mailUri),
      );

      if (result.isRight) {
        return Right(result.right);
      }

      return Left(WebEmailLaunchFailure(cause: result.left.cause));
    }

    // For mobile platforms only
    final result = await composeEmail(input);
    if (!result.didOpen) {
      return const Left(NoEmailAppFoundFailure());
    }
    return Right(result.didOpen);
  }

  @protected
  @override
  OpenEmailFailure mapErrorToFailure(Object e, StackTrace st) {
    return EmailLaunchFailure(cause: e);
  }
}
