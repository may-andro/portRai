import 'dart:async';

import 'package:core/core.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/locale/domain/repository/locale_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetLocaleFailure extends BasicFailure {
  const GetLocaleFailure({super.cause});
}

@Localizable('errorLocaleFailedToLoadFromCache')
class GetLocaleCacheFailure extends GetLocaleFailure {
  const GetLocaleCacheFailure({super.cause});
}

@Localizable('errorLocaleFailedToLoadUnknownReason')
class GetLocaleUnknownFailure extends GetLocaleFailure {
  const GetLocaleUnknownFailure({super.cause});
}

@register
class GetLocaleUseCase extends BaseNoParamUseCase<AppLocale, GetLocaleFailure> {
  GetLocaleUseCase(this._localeRepository);

  final LocaleRepository _localeRepository;

  @protected
  @override
  FutureOr<Either<GetLocaleFailure, AppLocale>> execute() async {
    final appLocale = await _localeRepository.appLocale;
    return Right(appLocale);
  }

  @protected
  @override
  GetLocaleFailure mapErrorToFailure(Object e, StackTrace st) {
    final errorMessage = e.toString().toLowerCase();

    // Cache-related errors (preferences, storage, file system issues)
    if (errorMessage.contains('preferences') ||
        errorMessage.contains('cache') ||
        errorMessage.contains('storage') ||
        errorMessage.contains('file') ||
        errorMessage.contains('disk') ||
        errorMessage.contains('space') ||
        errorMessage.contains('permission')) {
      return GetLocaleCacheFailure(cause: e);
    }

    // Default to unknown failure for any other unexpected errors
    return GetLocaleUnknownFailure(cause: e);
  }
}
