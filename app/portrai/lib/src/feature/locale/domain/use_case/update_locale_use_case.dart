import 'dart:async';

import 'package:core/core.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/locale/domain/repository/locale_repository.dart';
import 'package:use_case/use_case.dart';

sealed class UpdateLocaleFailure extends BasicFailure {
  const UpdateLocaleFailure({super.cause});
}

@Localizable('errorLocaleFailedToSaveToCache')
class UpdateLocaleCacheFailure extends UpdateLocaleFailure {
  const UpdateLocaleCacheFailure({super.cause});
}

@Localizable('errorLocaleFailedToUpdateServiceLocator')
class UpdateLocaleServiceLocatorFailure extends UpdateLocaleFailure {
  const UpdateLocaleServiceLocatorFailure({super.cause});
}

@Localizable('errorLocaleFailedToUpdateUnknownReason')
class UpdateLocaleUnknownFailure extends UpdateLocaleFailure {
  const UpdateLocaleUnknownFailure({super.cause});
}

@register
class UpdateLocaleUseCase
    extends BaseUseCase<void, AppLocale, UpdateLocaleFailure> {
  UpdateLocaleUseCase(this._localeRepository);

  final LocaleRepository _localeRepository;

  @protected
  @override
  FutureOr<Either<UpdateLocaleFailure, void>> execute(AppLocale input) async {
    await _localeRepository.updateAppLocale(input);
    return const Right(null);
  }

  @protected
  @override
  UpdateLocaleFailure mapErrorToFailure(Object e, StackTrace st) {
    final errorMessage = e.toString().toLowerCase();

    // Cache-related errors (AppLocaleCache.put() failures)
    if (errorMessage.contains('cache') ||
        errorMessage.contains('preferences') ||
        errorMessage.contains('storage') ||
        errorMessage.contains('disk') ||
        errorMessage.contains('space') ||
        errorMessage.contains('permission')) {
      return UpdateLocaleCacheFailure(cause: e);
    }

    // Service locator errors (unregister/register failures)
    if (errorMessage.contains('locator') ||
        errorMessage.contains('register') ||
        errorMessage.contains('unregister') ||
        errorMessage.contains('dependency') ||
        errorMessage.contains('injection')) {
      return UpdateLocaleServiceLocatorFailure(cause: e);
    }

    // Default to unknown failure for any other unexpected errors
    return UpdateLocaleUnknownFailure(cause: e);
  }
}
