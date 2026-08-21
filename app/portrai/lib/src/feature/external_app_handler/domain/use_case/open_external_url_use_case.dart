import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:use_case/use_case.dart';

@Localizable('errorExternalUrlLaunch')
class OpenExternalUrlFailure extends BasicFailure {
  const OpenExternalUrlFailure({super.cause});
}

class OpenExternalUrlParam {
  const OpenExternalUrlParam(this.uri, {this.forceWebView = false});

  final Uri uri;
  final bool forceWebView;
}

@register
class OpenExternalUrlUseCase
    extends BaseUseCase<bool, OpenExternalUrlParam, OpenExternalUrlFailure> {
  @protected
  @override
  FutureOr<Either<OpenExternalUrlFailure, bool>> execute(
    OpenExternalUrlParam input,
  ) async {
    final result = await launchUrl(
      input.uri,
      mode: input.forceWebView
          ? LaunchMode.inAppWebView
          : LaunchMode.externalApplication,
    );

    return Right(result);
  }

  @protected
  @override
  OpenExternalUrlFailure mapErrorToFailure(Object e, StackTrace st) {
    throw OpenExternalUrlFailure(cause: st);
  }
}
