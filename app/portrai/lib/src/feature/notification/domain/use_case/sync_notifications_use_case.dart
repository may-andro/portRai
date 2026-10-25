import 'dart:async';

import 'package:core/core.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/locale/locale.dart';
import 'package:portrai/src/feature/notification/domain/exception/_exception.dart';
import 'package:portrai/src/feature/notification/domain/repository/_repository.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:use_case/use_case.dart';

sealed class SyncNotificationsFailure extends BasicFailure {
  const SyncNotificationsFailure({super.cause});
}

class SyncNotificationsPermissionFailure extends SyncNotificationsFailure {
  const SyncNotificationsPermissionFailure({super.cause});
}

class SyncNotificationsTokenFailure extends SyncNotificationsFailure {
  const SyncNotificationsTokenFailure({super.cause});
}

class SyncNotificationsTopicFailure extends SyncNotificationsFailure {
  const SyncNotificationsTopicFailure({super.cause});
}

class SyncNotificationsDeviceFailure extends SyncNotificationsFailure {
  const SyncNotificationsDeviceFailure({super.cause});
}

class SyncNotificationsUnknownFailure extends SyncNotificationsFailure {
  const SyncNotificationsUnknownFailure({super.cause});
}

/// Matches this device's notifications to the app's current state: while
/// notifications are allowed, it receives the portfolio updates in the app's
/// language, and when a user is signed in, it is registered as their device.
/// Takes the language codes the app supports, so the updates in the other
/// languages stop.
@register
class SyncNotificationsUseCase
    extends BaseUseCase<void, List<String>, SyncNotificationsFailure> {
  SyncNotificationsUseCase(
    this._getPermissionStatusUseCase,
    this._getLocaleUseCase,
    this._getSignedInUserUseCase,
    this._notificationRepository,
  );

  final GetPermissionStatusUseCase _getPermissionStatusUseCase;
  final GetLocaleUseCase _getLocaleUseCase;
  final GetSignedInUserUseCase _getSignedInUserUseCase;
  final NotificationRepository _notificationRepository;

  @protected
  @override
  FutureOr<Either<SyncNotificationsFailure, void>> execute(
    List<String> supportedLanguageCodes,
  ) async {
    final permissionStatusEither = await _getPermissionStatusUseCase(
      AppPermission.notifications,
    );
    if (permissionStatusEither.isLeft) {
      return Left(
        SyncNotificationsPermissionFailure(cause: permissionStatusEither.left),
      );
    }
    if (!permissionStatusEither.right.isGranted) return const Right(null);

    final token = await _notificationRepository.getDeviceToken();
    if (token == null) return const Right(null);

    final localeEither = await _getLocaleUseCase();
    final languageCode = localeEither.isRight
        ? localeEither.right.languageCode
        : AppLocale.fallback().languageCode;
    await _notificationRepository.subscribeToPortfolioUpdates(
      languageCode: languageCode,
      otherLanguageCodes: supportedLanguageCodes
          .where((supportedCode) => supportedCode != languageCode)
          .toList(),
    );

    final signedInUserEither = await _getSignedInUserUseCase();
    if (signedInUserEither.isLeft) {
      return Left(
        SyncNotificationsUnknownFailure(cause: signedInUserEither.left),
      );
    }
    if (signedInUserEither.right case final signedInUser?) {
      await _notificationRepository.registerDevice(
        userId: signedInUser.id,
        token: token,
        languageCode: languageCode,
      );
    }
    return const Right(null);
  }

  @protected
  @override
  SyncNotificationsFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    NotificationTokenException() => SyncNotificationsTokenFailure(cause: error),
    NotificationTopicException() => SyncNotificationsTopicFailure(cause: error),
    NotificationDeviceException() => SyncNotificationsDeviceFailure(
      cause: error,
    ),
    _ => SyncNotificationsUnknownFailure(cause: error),
  };
}
