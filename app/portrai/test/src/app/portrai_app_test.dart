import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/app/portrai_app.dart';
import 'package:portrai/src/feature/connectivity/presentation/bloc/connectivity_bloc.dart';
import 'package:portrai/src/feature/force_update/domain/use_case/is_app_update_required_use_case.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/force_update_bloc.dart';
import 'package:portrai/src/feature/locale/domain/use_case/get_locale_use_case.dart';
import 'package:portrai/src/feature/locale/domain/use_case/update_locale_use_case.dart';
import 'package:portrai/src/feature/notification/presentation/bloc/notification_listener_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';
import 'package:use_case/use_case.dart';

import '../../mock/feature/auth/domain/use_case/mock_watch_signed_in_user_use_case.dart';
import '../../mock/feature/connectivity/domain/use_case/mock_check_internet_connection_use_case.dart';
import '../../mock/feature/connectivity/domain/use_case/mock_watch_internet_connection_use_case.dart';
import '../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../mock/feature/force_update/domain/use_case/mock_get_app_store_url_use_case.dart';
import '../../mock/feature/force_update/domain/use_case/mock_is_app_update_required_use_case.dart';
import '../../mock/feature/force_update/presentation/tracking/mock_force_update_tracking_delegate.dart';
import '../../mock/feature/locale/domain/use_case/mock_get_locale_use_case.dart';
import '../../mock/feature/locale/domain/use_case/mock_update_locale_use_case.dart';
import '../../mock/feature/locale/domain/use_case/mock_watch_locale_use_case.dart';
import '../../mock/feature/locale/test_data/locale_test_data.dart';
import '../../mock/feature/notification/domain/use_case/mock_get_initial_push_message_use_case.dart';
import '../../mock/feature/notification/domain/use_case/mock_reset_device_token_use_case.dart';
import '../../mock/feature/notification/domain/use_case/mock_sync_notifications_use_case.dart';
import '../../mock/feature/notification/domain/use_case/mock_watch_device_token_refreshes_use_case.dart';
import '../../mock/feature/notification/domain/use_case/mock_watch_foreground_push_messages_use_case.dart';
import '../../mock/feature/notification/domain/use_case/mock_watch_opened_push_messages_use_case.dart';
import '../../mock/utility/mock_module_route_controller.dart';

void main() {
  group('PortraiApp', () {
    setUp(() async {
      await appServiceLocator.reset();
      final isAppUpdateRequiredUseCase = MockIsAppUpdateRequiredUseCase()
        ..stubCall(const Right<IsAppUpdateRequiredFailure, bool>(false));
      appServiceLocator.registerFactory<ForceUpdateBloc>(
        () => ForceUpdateBloc(
          isAppUpdateRequiredUseCase: isAppUpdateRequiredUseCase,
          getAppStoreUrlUseCase: MockGetAppStoreUrlUseCase(),
          openExternalUrlUseCase: MockOpenExternalUrlUseCase(),
          trackingDelegate: MockForceUpdateTrackingDelegate(),
        ),
      );
      appServiceLocator.registerFactory<ConnectivityBloc>(
        () => ConnectivityBloc(
          checkInternetConnectionUseCase: MockCheckInternetConnectionUseCase()
            ..stubCall(const Right(true)),
          watchInternetConnectionUseCase: MockWatchInternetConnectionUseCase()
            ..stubCall(const Stream.empty()),
        ),
      );
      appServiceLocator.registerFactory<NotificationListenerBloc>(
        () => NotificationListenerBloc(
          MockSyncNotificationsUseCase()..stubCall(),
          MockResetDeviceTokenUseCase()..stubCall(),
          MockGetInitialPushMessageUseCase()..stubCall(null),
          MockWatchOpenedPushMessagesUseCase()..stubCall(const Stream.empty()),
          MockWatchForegroundPushMessagesUseCase()
            ..stubCall(const Stream.empty()),
          MockWatchDeviceTokenRefreshesUseCase()
            ..stubCall(const Stream.empty()),
          MockWatchLocaleUseCase()..stubCall(const Stream.empty()),
          MockWatchSignedInUserUseCase()..stubCall(const Stream.empty()),
        ),
      );
      final getLocaleUseCase = MockGetLocaleUseCase()
        ..stubCall(Right<GetLocaleFailure, AppLocale>(createEnglishLocale()));
      appServiceLocator.registerSingleton<GetLocaleUseCase>(
        () => getLocaleUseCase,
      );
      final updateLocaleUseCase = MockUpdateLocaleUseCase();
      appServiceLocator.registerSingleton<UpdateLocaleUseCase>(
        () => updateLocaleUseCase,
      );
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    GoRouterConfigurator buildRouteConfigurator() {
      final controller = MockModuleRouteController();
      when(() => controller.redirects).thenReturn(const []);
      when(() => controller.allRoutes).thenReturn([
        ModuleRoute(
          name: 'home',
          path: '/',
          builder: (_, _, _) => const Scaffold(body: Text('Home')),
        ),
      ]);
      return GoRouterConfigurator(controller, const []);
    }

    Future<RouterConfig<Object>> pumpApp(
      WidgetTester tester, {
      required GoRouterConfigurator routeConfigurator,
      required AppLocale appLocale,
    }) async {
      await tester.pumpWidget(
        PortraiApp(
          buildConfig: BuildConfig(buildEnvironment: BuildEnvironment.prod),
          designSystem: DesignSystem.beltane,
          routeConfigurator: routeConfigurator,
          appLocale: appLocale,
        ),
      );
      await tester.pump();
      return tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig!;
    }

    testWidgets('should keep the same router when rebuilt with the same '
        'locale', (tester) async {
      final routeConfigurator = buildRouteConfigurator();
      final firstRouter = await pumpApp(
        tester,
        routeConfigurator: routeConfigurator,
        appLocale: createEnglishLocale(),
      );

      final rebuiltRouter = await pumpApp(
        tester,
        routeConfigurator: routeConfigurator,
        appLocale: createEnglishLocale(),
      );

      expect(rebuiltRouter, same(firstRouter));
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('should create a new router when the locale changes', (
      tester,
    ) async {
      final routeConfigurator = buildRouteConfigurator();
      final englishRouter = await pumpApp(
        tester,
        routeConfigurator: routeConfigurator,
        appLocale: createEnglishLocale(),
      );

      final dutchRouter = await pumpApp(
        tester,
        routeConfigurator: routeConfigurator,
        appLocale: createDutchLocale(),
      );

      expect(dutchRouter, isNot(same(englishRouter)));
      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
