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

  @protected
  @override
  FutureOr<Either<OpenEmailFailure, bool>> execute(String input) async {
    const emailSubject = 'Virtual Call Opportunity';
    const emailBody =
        'Hello,\n\nI would like to arrange a virtual call to get in touch with you regarding an exciting opportunity.\n\nThank you!';

    if (kIsWeb) {
      final String encodedSubject = Uri.encodeComponent(emailSubject);
      final String encodedBody = Uri.encodeComponent(emailBody);
      final String mailtoUrl =
          'mailto:$input?subject=$encodedSubject&body=$encodedBody';
      final Uri mailUri = Uri.parse(mailtoUrl);

      final eitherResult = await _openExternalUrlUseCase(
        OpenExternalUrlParam(mailUri),
      );
      return eitherResult.mapLeft(
        (failure) => WebEmailLaunchFailure(cause: failure.cause),
      );
    }

    // For mobile platforms only
    final result = await OpenMail.composeNewEmailInMailApp(
      emailContent: EmailContent(
        to: [input],
        subject: emailSubject,
        body: emailBody,
      ),
    );
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
