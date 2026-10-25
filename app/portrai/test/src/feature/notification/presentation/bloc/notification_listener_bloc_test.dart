import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:portrai/src/feature/notification/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/auth/domain/use_case/mock_watch_signed_in_user_use_case.dart';
import '../../../../../mock/feature/locale/domain/use_case/mock_watch_locale_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_get_initial_push_message_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_reset_device_token_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_sync_notifications_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_watch_device_token_refreshes_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_watch_foreground_push_messages_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_watch_opened_push_messages_use_case.dart';
import '../../../../../mock/feature/portfolio/domain/use_case/mock_update_portfolio_use_case.dart';

const _languageCodes = ['en', 'es'];
const _owner = AuthUserEntity(id: 'owner-uid', email: null);
const _jobsMessage = PushMessageEntity(
  kind: PushMessageKind.jobOpenings,
  title: 'New jobs for you',
);
const _portfolioMessage = PushMessageEntity(
  kind: PushMessageKind.portfolioUpdate,
  title: 'Portfolio updated',
);

void main() {
  group('NotificationListenerBloc', () {
    late MockSyncNotificationsUseCase syncNotificationsUseCase;
    late MockResetDeviceTokenUseCase resetDeviceTokenUseCase;
    late MockGetInitialPushMessageUseCase getInitialPushMessageUseCase;
    late StreamController<PushMessageEntity> openedMessages;
    late StreamController<PushMessageEntity> foregroundMessages;
    late StreamController<String> tokenRefreshes;
    late StreamController<AppLocale> locales;
    late StreamController<AuthUserEntity?> signedInUsers;
    late MockUpdatePortfolioUseCase updatePortfolioUseCase;

    setUp(() {
      syncNotificationsUseCase = MockSyncNotificationsUseCase()..stubCall();
      resetDeviceTokenUseCase = MockResetDeviceTokenUseCase()..stubCall();
      getInitialPushMessageUseCase = MockGetInitialPushMessageUseCase()
        ..stubCall(null);
      openedMessages = StreamController.broadcast();
      foregroundMessages = StreamController.broadcast();
      tokenRefreshes = StreamController.broadcast();
      locales = StreamController.broadcast();
      signedInUsers = StreamController.broadcast();
      updatePortfolioUseCase = MockUpdatePortfolioUseCase()
        ..stubCall(const Right({}));
    });

    NotificationListenerBloc buildBloc() {
      final bloc = NotificationListenerBloc(
        syncNotificationsUseCase,
        resetDeviceTokenUseCase,
        getInitialPushMessageUseCase,
        MockWatchOpenedPushMessagesUseCase()
          ..stubCall(openedMessages.stream.map(Right.new)),
        MockWatchForegroundPushMessagesUseCase()
          ..stubCall(foregroundMessages.stream.map(Right.new)),
        MockWatchDeviceTokenRefreshesUseCase()
          ..stubCall(tokenRefreshes.stream.map(Right.new)),
        MockWatchLocaleUseCase()..stubCall(locales.stream.map(Right.new)),
        MockWatchSignedInUserUseCase()
          ..stubCall(signedInUsers.stream.map(Right.new)),
        updatePortfolioUseCase,
      );
      addTearDown(bloc.close);
      return bloc;
    }

    Future<NotificationListenerBloc> startBloc() async {
      final bloc = buildBloc()
        ..add(const NotificationListenerStartEvent(_languageCodes));
      await pumpEventQueue();
      return bloc;
    }

    test('should sync with the supported languages when the restored session '
        'arrives', () async {
      await startBloc();

      signedInUsers.add(_owner);
      await pumpEventQueue();

      verify(() => syncNotificationsUseCase(_languageCodes)).called(1);
      verifyNever(resetDeviceTokenUseCase.call);
    });

    test(
      'should reset the token before syncing when the user signs out',
      () async {
        await startBloc();

        signedInUsers
          ..add(_owner)
          ..add(null);
        await pumpEventQueue();

        verifyInOrder([
          () => syncNotificationsUseCase(_languageCodes),
          resetDeviceTokenUseCase.call,
          () => syncNotificationsUseCase(_languageCodes),
        ]);
      },
    );

    test('should not reset the token when the app starts signed out', () async {
      await startBloc();

      signedInUsers.add(null);
      await pumpEventQueue();

      verifyNever(resetDeviceTokenUseCase.call);
    });

    test('should sync again when the language or the token changes', () async {
      await startBloc();

      locales.add(AppLocale('es'));
      tokenRefreshes.add('new-token');
      await pumpEventQueue();

      verify(() => syncNotificationsUseCase(_languageCodes)).called(2);
    });

    test(
      'should report the message that opened the app when starting',
      () async {
        getInitialPushMessageUseCase.stubCall(_jobsMessage);
        final bloc = buildBloc();
        final states = expectLater(
          bloc.stream,
          emits(
            isA<PushMessageOpenedState>().having(
              (state) => state.message,
              'message',
              _jobsMessage,
            ),
          ),
        );

        bloc.add(const NotificationListenerStartEvent(_languageCodes));

        await states;
      },
    );

    test('should report every tapped and received message', () async {
      final bloc = await startBloc();
      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PushMessageOpenedState>(),
          isA<PushMessageOpenedState>(),
          isA<PushMessageReceivedState>(),
        ]),
      );

      for (final messages in [
        openedMessages,
        openedMessages,
        foregroundMessages,
      ]) {
        messages.add(_jobsMessage);
        await pumpEventQueue();
      }

      await states;
    });

    test('should update the portfolio when a portfolio update is tapped or '
        'received', () async {
      await startBloc();

      openedMessages.add(_portfolioMessage);
      await pumpEventQueue();
      foregroundMessages.add(_portfolioMessage);
      await pumpEventQueue();

      verify(() => updatePortfolioUseCase()).called(2);
    });

    test(
      'should update the portfolio when a portfolio update opened the app',
      () async {
        getInitialPushMessageUseCase.stubCall(_portfolioMessage);

        await startBloc();

        verify(() => updatePortfolioUseCase()).called(1);
      },
    );

    test(
      'should not update the portfolio when another message arrives',
      () async {
        await startBloc();

        openedMessages.add(_jobsMessage);
        foregroundMessages.add(_jobsMessage);
        await pumpEventQueue();

        verifyNever(() => updatePortfolioUseCase());
      },
    );
  });
}
