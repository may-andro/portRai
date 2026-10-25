import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/locale.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/auth/domain/use_case/mock_get_signed_in_user_use_case.dart';
import '../../../../../mock/feature/locale/domain/use_case/mock_get_locale_use_case.dart';
import '../../../../../mock/feature/notification/domain/repository/mock_notification_repository.dart';
import '../../../../../mock/feature/permission/domain/use_case/mock_get_permission_status_use_case.dart';

const _languageCodes = ['en', 'es', 'nl'];

void main() {
  group('SyncNotificationsUseCase', () {
    late MockGetPermissionStatusUseCase getPermissionStatusUseCase;
    late MockGetLocaleUseCase getLocaleUseCase;
    late MockGetSignedInUserUseCase getSignedInUserUseCase;
    late MockNotificationRepository notificationRepository;

    setUp(() {
      getPermissionStatusUseCase = MockGetPermissionStatusUseCase()
        ..stubCall(
          AppPermission.notifications,
          const Right(AppPermissionStatus.granted),
        );
      getLocaleUseCase = MockGetLocaleUseCase()
        ..stubCall(Right(AppLocale('es')));
      getSignedInUserUseCase = MockGetSignedInUserUseCase()
        ..stubCall(const Right(AuthUserEntity(id: 'owner-uid', email: null)));
      notificationRepository = MockNotificationRepository()
        ..stubGetDeviceToken('device-token')
        ..stubSubscribeToPortfolioUpdates()
        ..stubRegisterDevice();
    });

    SyncNotificationsUseCase buildUseCase() => SyncNotificationsUseCase(
      getPermissionStatusUseCase,
      getLocaleUseCase,
      getSignedInUserUseCase,
      notificationRepository,
    );

    test('should subscribe to the language and register the device when '
        'notifications are allowed and a user is signed in', () async {
      final syncNotificationsEither = await buildUseCase()(_languageCodes);

      expect(syncNotificationsEither.isRight, isTrue);
      verify(
        () => notificationRepository.subscribeToPortfolioUpdates(
          languageCode: 'es',
          otherLanguageCodes: ['en', 'nl'],
        ),
      ).called(1);
      verify(
        () => notificationRepository.registerDevice(
          userId: 'owner-uid',
          token: 'device-token',
          languageCode: 'es',
        ),
      ).called(1);
    });

    test('should subscribe without registering a device when nobody is '
        'signed in', () async {
      getSignedInUserUseCase.stubCall(const Right(null));

      final syncNotificationsEither = await buildUseCase()(_languageCodes);

      expect(syncNotificationsEither.isRight, isTrue);
      verify(
        () => notificationRepository.subscribeToPortfolioUpdates(
          languageCode: 'es',
          otherLanguageCodes: any(named: 'otherLanguageCodes'),
        ),
      ).called(1);
      verifyNever(
        () => notificationRepository.registerDevice(
          userId: any(named: 'userId'),
          token: any(named: 'token'),
          languageCode: any(named: 'languageCode'),
        ),
      );
    });

    for (final status in [
      AppPermissionStatus.denied,
      AppPermissionStatus.permanentlyDenied,
    ]) {
      test('should do nothing when the permission is $status', () async {
        getPermissionStatusUseCase.stubCall(
          AppPermission.notifications,
          Right(status),
        );

        final syncNotificationsEither = await buildUseCase()(_languageCodes);

        expect(syncNotificationsEither.isRight, isTrue);
        verifyZeroInteractions(notificationRepository);
      });
    }

    test('should do nothing more when the device has no token', () async {
      notificationRepository.stubGetDeviceToken(null);

      final syncNotificationsEither = await buildUseCase()(_languageCodes);

      expect(syncNotificationsEither.isRight, isTrue);
      verifyNever(
        () => notificationRepository.subscribeToPortfolioUpdates(
          languageCode: any(named: 'languageCode'),
          otherLanguageCodes: any(named: 'otherLanguageCodes'),
        ),
      );
    });

    test(
      'should use the fallback language when the locale cannot be read',
      () async {
        getLocaleUseCase.stubCall(const Left(GetLocaleUnknownFailure()));

        await buildUseCase()(_languageCodes);

        verify(
          () => notificationRepository.subscribeToPortfolioUpdates(
            languageCode: 'en',
            otherLanguageCodes: ['es', 'nl'],
          ),
        ).called(1);
      },
    );

    test('should return a permission failure when the permission cannot be '
        'read', () async {
      getPermissionStatusUseCase.stubCall(
        AppPermission.notifications,
        const Left(GetPermissionStatusUnknownFailure()),
      );

      final syncNotificationsEither = await buildUseCase()(_languageCodes);

      expect(
        syncNotificationsEither.left,
        isA<SyncNotificationsPermissionFailure>(),
      );
    });

    for (final (exception, failureMatcher) in [
      (
        const NotificationTokenException(),
        isA<SyncNotificationsTokenFailure>(),
      ),
      (
        const NotificationDeviceException(),
        isA<SyncNotificationsDeviceFailure>(),
      ),
      (StateError('broken'), isA<SyncNotificationsUnknownFailure>()),
    ]) {
      test(
        'should map ${exception.runtimeType} when the repository throws it',
        () async {
          notificationRepository.stubRegisterDeviceThrows(exception);

          final syncNotificationsEither = await buildUseCase()(_languageCodes);

          expect(syncNotificationsEither.left, failureMatcher);
        },
      );
    }
  });
}
