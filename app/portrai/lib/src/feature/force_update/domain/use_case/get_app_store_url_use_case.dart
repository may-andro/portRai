import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/force_update/domain/repository/app_version_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetAppStoreUrlFailure extends BasicFailure {
  const GetAppStoreUrlFailure({super.cause});
}

@Localizable('errorForceUpdateStoreUrl')
class GetAppStoreUrlUnknownFailure extends GetAppStoreUrlFailure {
  const GetAppStoreUrlUnknownFailure({super.cause});
}

/// Builds the store URL the user should be sent to in order to update the app.
@register
class GetAppStoreUrlUseCase
    extends BaseNoParamUseCase<Uri, GetAppStoreUrlFailure> {
  GetAppStoreUrlUseCase(this._appVersionRepository);

  final AppVersionRepository _appVersionRepository;

  // TODO(ios): Replace with the real numeric App Store ID once the app is
  // published on the App Store (e.g. from an App Store Connect URL such as
  // `https://apps.apple.com/app/id1234567890`).
  static const _iosAppStoreId = 'REPLACE_WITH_APP_STORE_ID';

  @protected
  @override
  FutureOr<Either<GetAppStoreUrlFailure, Uri>> execute() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Right(Uri.parse('https://apps.apple.com/app/id$_iosAppStoreId'));
    }

    final packageName = await _appVersionRepository.getPackageName();
    return Right(
      Uri.parse('https://play.google.com/store/apps/details?id=$packageName'),
    );
  }

  @protected
  @override
  GetAppStoreUrlFailure mapErrorToFailure(Object e, StackTrace st) {
    return GetAppStoreUrlUnknownFailure(cause: e);
  }
}
