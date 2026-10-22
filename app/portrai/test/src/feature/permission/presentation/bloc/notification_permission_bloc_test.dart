import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/permission.dart';
import 'package:portrai/src/feature/permission/presentation/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/permission/domain/use_case/mock_get_permission_status_use_case.dart';
import '../../../../../mock/feature/permission/domain/use_case/mock_open_permission_settings_use_case.dart';
import '../../../../../mock/feature/permission/domain/use_case/mock_request_permission_use_case.dart';

void main() {
  const notifications = AppPermission.notifications;
  late MockGetPermissionStatusUseCase getStatus;
  late MockRequestPermissionUseCase request;
  late MockOpenPermissionSettingsUseCase openSettings;

  NotificationPermissionBloc createBloc({
    AppPermissionStatus status = AppPermissionStatus.denied,
  }) {
    getStatus = MockGetPermissionStatusUseCase()
      ..stubCall(notifications, Right(status));
    request = MockRequestPermissionUseCase()
      ..stubCall(notifications, const Right(AppPermissionStatus.granted));
    openSettings = MockOpenPermissionSettingsUseCase()
      ..stubCall(const Right(null));
    return NotificationPermissionBloc(getStatus, request, openSettings);
  }

  blocTest<NotificationPermissionBloc, NotificationPermissionState>(
    'should show the system status when the setting becomes visible',
    build: () => createBloc(status: AppPermissionStatus.granted),
    act: (bloc) => bloc.add(const NotificationPermissionVisibleEvent()),
    expect: () => [
      const NotificationPermissionState(status: AppPermissionStatus.granted),
    ],
  );

  blocTest<NotificationPermissionBloc, NotificationPermissionState>(
    'should show the system prompt when turned on while it is offered',
    build: createBloc,
    seed: () =>
        const NotificationPermissionState(status: AppPermissionStatus.denied),
    act: (bloc) =>
        bloc.add(const NotificationPermissionToggleClickEvent(enabled: true)),
    expect: () => [
      const NotificationPermissionState(status: AppPermissionStatus.granted),
    ],
    verify: (_) => verifyNever(() => openSettings()),
  );

  blocTest<NotificationPermissionBloc, NotificationPermissionState>(
    'should open the device settings when turned on after a permanent denial',
    build: createBloc,
    seed: () => const NotificationPermissionState(
      status: AppPermissionStatus.permanentlyDenied,
    ),
    act: (bloc) =>
        bloc.add(const NotificationPermissionToggleClickEvent(enabled: true)),
    expect: () => const <NotificationPermissionState>[],
    verify: (_) {
      verify(() => openSettings()).called(1);
      verifyNever(() => request(notifications));
    },
  );

  blocTest<NotificationPermissionBloc, NotificationPermissionState>(
    'should open the device settings when turned off',
    build: createBloc,
    seed: () =>
        const NotificationPermissionState(status: AppPermissionStatus.granted),
    act: (bloc) =>
        bloc.add(const NotificationPermissionToggleClickEvent(enabled: false)),
    verify: (_) => verify(() => openSettings()).called(1),
  );

  blocTest<NotificationPermissionBloc, NotificationPermissionState>(
    'should show a failure when the device settings do not open',
    build: () {
      final bloc = createBloc();
      openSettings.stubCall(const Left(OpenPermissionSettingsUnknownFailure()));
      return bloc;
    },
    seed: () =>
        const NotificationPermissionState(status: AppPermissionStatus.granted),
    act: (bloc) =>
        bloc.add(const NotificationPermissionToggleClickEvent(enabled: false)),
    expect: () => [
      const NotificationPermissionState(
        status: AppPermissionStatus.granted,
        failure: OpenPermissionSettingsUnknownFailure(),
      ),
    ],
  );
}
