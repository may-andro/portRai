import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/permission/presentation/bloc/_bloc.dart';

class MockNotificationPermissionBloc
    extends MockBloc<NotificationPermissionEvent, NotificationPermissionState>
    implements NotificationPermissionBloc {}

extension MockNotificationPermissionBlocStub on MockNotificationPermissionBloc {
  void stubState(NotificationPermissionState state) {
    when(() => this.state).thenReturn(state);
  }
}
