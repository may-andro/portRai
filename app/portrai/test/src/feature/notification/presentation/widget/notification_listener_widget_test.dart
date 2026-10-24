import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:portrai/src/feature/notification/presentation/_presentation.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';

import '../../../../../mock/feature/auth/domain/use_case/mock_get_signed_in_user_stream_use_case.dart';
import '../../../../../mock/feature/locale/domain/use_case/mock_get_locale_stream_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_get_device_token_refresh_stream_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_get_foreground_push_message_stream_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_get_initial_push_message_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_get_opened_push_message_stream_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_reset_device_token_use_case.dart';
import '../../../../../mock/feature/notification/domain/use_case/mock_sync_notifications_use_case.dart';
import '../../../../../mock/utility/mock_module_route_controller.dart';

void main() {
  group('NotificationListenerWidget', () {
    late StreamController<PushMessageEntity> openedMessages;
    late StreamController<PushMessageEntity> foregroundMessages;
    late MockSyncNotificationsUseCase syncNotificationsUseCase;

    setUp(() async {
      await appServiceLocator.reset();
      openedMessages = StreamController.broadcast();
      foregroundMessages = StreamController.broadcast();
      syncNotificationsUseCase = MockSyncNotificationsUseCase()..stubCall();
      appServiceLocator.registerFactory<NotificationListenerBloc>(
        () => NotificationListenerBloc(
          syncNotificationsUseCase,
          MockResetDeviceTokenUseCase()..stubCall(),
          MockGetInitialPushMessageUseCase()..stubCall(null),
          MockGetOpenedPushMessageStreamUseCase()
            ..stubCall(openedMessages.stream),
          MockGetForegroundPushMessageStreamUseCase()
            ..stubCall(foregroundMessages.stream),
          MockGetDeviceTokenRefreshStreamUseCase()
            ..stubCall(const Stream.empty()),
          MockGetLocaleStreamUseCase()..stubCall(const Stream.empty()),
          MockGetSignedInUserStreamUseCase()..stubCall(const Stream.empty()),
        ),
      );
    });

    tearDown(appServiceLocator.reset);

    Future<void> pumpApp(WidgetTester tester) async {
      final controller = MockModuleRouteController();
      when(() => controller.redirects).thenReturn(const []);
      when(() => controller.allRoutes).thenReturn([
        ModuleRoute(
          name: '/',
          path: '/',
          builder: (_, _, _) => const Scaffold(body: Text('Portfolio')),
        ),
        ModuleRoute(
          name: 'job_openings',
          path: '/job-openings',
          builder: (_, _, _) => const Scaffold(body: Text('Job openings')),
        ),
      ]);
      final router = GoRouterConfigurator(controller, const []).createRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => DSThemeBuilderWidget(
            brightness: Brightness.light,
            designSystem: DesignSystem.beltane,
            child: NotificationListenerWidget(child: child!),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('should open the job openings when their notification is '
        'tapped', (tester) async {
      await pumpApp(tester);

      openedMessages.add(
        const PushMessageEntity(kind: PushMessageKind.jobOpenings),
      );
      await tester.pumpAndSettle();

      expect(find.text('Job openings'), findsOneWidget);
    });

    testWidgets('should go to the portfolio when its update notification is '
        'tapped', (tester) async {
      await pumpApp(tester);
      openedMessages.add(
        const PushMessageEntity(kind: PushMessageKind.jobOpenings),
      );
      await tester.pumpAndSettle();

      openedMessages.add(
        const PushMessageEntity(kind: PushMessageKind.portfolioUpdate),
      );
      await tester.pumpAndSettle();

      expect(find.text('Portfolio'), findsOneWidget);
      expect(find.text('Job openings'), findsNothing);
    });

    testWidgets('should show a notification that arrives in the foreground', (
      tester,
    ) async {
      await pumpApp(tester);

      foregroundMessages.add(
        const PushMessageEntity(
          kind: PushMessageKind.jobOpenings,
          title: 'New jobs for you',
          body: '2 new job openings match your portfolio.',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(
        find.textContaining(
          'New jobs for you · 2 new job openings match your portfolio.',
        ),
        findsOneWidget,
      );
    });
  });
}
