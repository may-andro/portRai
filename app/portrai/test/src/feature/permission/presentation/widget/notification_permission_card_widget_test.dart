import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:portrai/src/feature/permission/presentation/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../mock/feature/permission/presentation/bloc/mock_notification_permission_bloc.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  setUp(() => appServiceLocator.reset());
  tearDown(() => appServiceLocator.reset());
  setUpAll(
    () => registerFallbackValue(const NotificationPermissionVisibleEvent()),
  );

  Future<MockNotificationPermissionBloc> pumpCard(
    WidgetTester tester,
    NotificationPermissionState state,
  ) async {
    final bloc = MockNotificationPermissionBloc()..stubState(state);
    appServiceLocator.registerFactory<NotificationPermissionBloc>(() => bloc);
    await tester.pumpWidget(
      const TestWidgetWrapper(
        child: SingleChildScrollView(child: NotificationPermissionCardWidget()),
      ),
    );
    return bloc;
  }

  testWidgets('should read the system status when shown', (tester) async {
    final bloc = await pumpCard(tester, const NotificationPermissionState());

    verify(
      () => bloc.add(const NotificationPermissionVisibleEvent()),
    ).called(1);
  });

  testWidgets('should show the switch on when notifications are allowed', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const NotificationPermissionState(status: AppPermissionStatus.granted),
    );

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('should ask to turn notifications on when switched on', (
    tester,
  ) async {
    final bloc = await pumpCard(
      tester,
      const NotificationPermissionState(status: AppPermissionStatus.denied),
    );

    await tester.tap(find.byType(Switch));

    verify(
      () =>
          bloc.add(const NotificationPermissionToggleClickEvent(enabled: true)),
    ).called(1);
  });

  testWidgets('should disable the switch until the status is read', (
    tester,
  ) async {
    await pumpCard(tester, const NotificationPermissionState());

    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });
}
