import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/domain/entity/_entity.dart';
import 'package:use_case/use_case.dart';

sealed class GetPrivacyPolicyUrlFailure extends BasicFailure {
  const GetPrivacyPolicyUrlFailure({super.cause});
}

class GetPrivacyPolicyUrlUnknownFailure extends GetPrivacyPolicyUrlFailure {
  const GetPrivacyPolicyUrlUnknownFailure({super.cause});
}

/// The privacy policy page from the `privacyPolicyUrl` of [PortraiAppConfigEntity], or the hosted
/// page when it is missing or not a web address.
@register
class GetPrivacyPolicyUrlUseCase
    extends BaseNoParamUseCase<Uri, GetPrivacyPolicyUrlFailure> {
  GetPrivacyPolicyUrlUseCase(this._appConfig);

  static final defaultUrl = Uri.parse(
    'https://portrai-legal.web.app/privacy-policy',
  );

  final PortraiAppConfigEntity _appConfig;

  @protected
  @override
  FutureOr<Either<GetPrivacyPolicyUrlFailure, Uri>> execute() {
    final url = Uri.tryParse(_appConfig.privacyPolicyUrl?.trim() ?? '');
    final isWebUrl =
        url != null &&
        url.host.isNotEmpty &&
        (url.isScheme('https') || url.isScheme('http'));
    return Right(isWebUrl ? url : defaultUrl);
  }

  @protected
  @override
  GetPrivacyPolicyUrlFailure mapErrorToFailure(Object e, StackTrace st) {
    return GetPrivacyPolicyUrlUnknownFailure(cause: e);
  }
}
