import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';
import 'package:use_case/use_case.dart';

sealed class GetTermsUrlFailure extends BasicFailure {
  const GetTermsUrlFailure({super.cause});
}

class GetTermsUrlUnknownFailure extends GetTermsUrlFailure {
  const GetTermsUrlUnknownFailure({super.cause});
}

/// The terms page from the `termsUrl` of [PortraiAppConfigEntity], or the hosted
/// page when it is missing or not a web address.
@register
class GetTermsUrlUseCase extends BaseNoParamUseCase<Uri, GetTermsUrlFailure> {
  GetTermsUrlUseCase(this._appConfig);

  static final defaultUrl = Uri.parse('https://portrai-legal.web.app/terms');

  final PortraiAppConfigEntity _appConfig;

  @protected
  @override
  FutureOr<Either<GetTermsUrlFailure, Uri>> execute() {
    final url = Uri.tryParse(_appConfig.termsUrl?.trim() ?? '');
    final isWebUrl =
        url != null &&
        url.host.isNotEmpty &&
        (url.isScheme('https') || url.isScheme('http'));
    return Right(isWebUrl ? url : defaultUrl);
  }

  @protected
  @override
  GetTermsUrlFailure mapErrorToFailure(Object e, StackTrace st) {
    return GetTermsUrlUnknownFailure(cause: e);
  }
}
